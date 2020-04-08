# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController do
  include ActiveJob::TestHelper

  let(:response_json) { JSON.parse(response.body) }
  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: move, include: MoveSerializer::INCLUDED_ATTRIBUTES))
  end

  describe 'POST /moves' do
    let(:schema) { load_json_schema('post_moves_responses.json') }

    let(:move_attributes) {
      { date: Date.today,
        time_due: Time.now,
        status: 'requested',
        additional_information: 'some more info',
        move_type: 'court_appearance' }
    }

    let!(:from_location) { create :location, location_type: :prison, suppliers: [supplier] }
    let!(:to_location) { create :location, :court }
    let!(:person) { create(:person) }
    let!(:document) { create(:document) }
    let!(:reason) { create(:prison_transfer_reason) }
    let(:data) do
      {
        type: 'moves',
        attributes: move_attributes,
        relationships: {
          person: { data: { type: 'people', id: person.id } },
          from_location: { data: { type: 'locations', id: from_location.id } },
          to_location: to_location ? { data: { type: 'locations', id: to_location.id } } : nil,
          documents: { data: [{ type: 'documents', id: document.id }] },
          prison_transfer_reason: { data: { type: 'prison_transfer_reasons', id: reason.id } },
        },
      }
    end
    let(:supplier) { create(:supplier) }
    let!(:application) { create(:application, owner_id: supplier.id) }
    let(:access_token) { create(:access_token, application: application).token }
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
    let(:content_type) { ApiController::CONTENT_TYPE }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      post '/api/v1/moves', params: { data: data }, headers: headers, as: :json
    end

    context 'when not authorized', :skip_before, :with_invalid_auth_headers do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:content_type) { ApiController::CONTENT_TYPE }
      let(:detail_401) { 'Token expired or invalid' }

      before do
        post '/api/v1/moves', params: { data: data }, headers: headers, as: :json
      end

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before do
        post '/api/v1/moves', params: { data: data }, headers: headers, as: :json
      end

      it_behaves_like 'an endpoint that responds with error 415'
    end

    context 'when successful' do
      let(:move) { Move.find_by(from_location_id: from_location.id) }

      it_behaves_like 'an endpoint that responds with success 201'

      it 'creates a move', skip_before: true do
        expect { post '/api/v1/moves', params: { data: data }, headers: headers, as: :json }
          .to change(Move, :count).by(1)
      end

      it 'audits the supplier' do
        expect(move.versions.map(&:whodunnit)).to eq([supplier.id])
      end

      it 'associates the documents with the newly created move' do
        expect(move.documents).to eq([document])
      end

      it 'associates a reason with the newly created move' do
        expect(move.prison_transfer_reason).to eq(reason)
      end

      it 'returns the correct data' do
        expect(response_json).to eq resource_to_json
      end

      it 'sets the additional_information' do
        expect(response_json.dig('data', 'attributes', 'additional_information')).to match 'some more info'
      end

      context 'when the supplier has a webhook subscription', :skip_before do
        let!(:subscription) { create(:subscription, :no_email_address, supplier: supplier) }
        let!(:notification_type_webhook) { create(:notification_type, :webhook) }
        let(:notification) { subscription.notifications.last }
        let(:faraday_client) {
          class_double(Faraday, post:
            instance_double(Faraday::Response, success?: true, status: 202))
        }

        before do
          allow(Faraday).to receive(:new).and_return(faraday_client)
          perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
            post '/api/v1/moves', params: { data: data }, headers: headers, as: :json
          end
        end

        describe 'notification record' do
          it { expect(notification.delivered_at).not_to be_nil }
          it { expect(notification.topic).to eql(move) }
          it { expect(notification.notification_type).to eql(notification_type_webhook) }
          it { expect(notification.event_type).to eql('create_move') }
          it { expect(notification.response_id).to be_nil }
        end
      end

      context 'when the supplier has an email subscription', :skip_before do
        let!(:subscription) { create(:subscription, :no_callback_url, supplier: supplier) }
        let!(:notification_type_email) { create(:notification_type, :email) }
        let(:notification) { subscription.notifications.last }
        let(:notify_response) {
          instance_double(ActionMailer::MessageDelivery, deliver_now!:
              instance_double(Mail::Message, govuk_notify_response:
                  instance_double(Notifications::Client::ResponseNotification, id: response_id)))
        }
        let(:response_id) { SecureRandom.uuid }

        before do
          allow(MoveMailer).to receive(:notify).and_return(notify_response)
          perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyEmailJob]) do
            post '/api/v1/moves', params: { data: data }, headers: headers, as: :json
          end
        end

        describe 'notification record' do
          it { expect(notification.delivered_at).not_to be_nil }
          it { expect(notification.topic).to eql(move) }
          it { expect(notification.notification_type).to eql(notification_type_email) }
          it { expect(notification.event_type).to eql('create_move') }
          it { expect(notification.response_id).to eql(response_id) }
        end
      end

      context 'without a `to_location`' do
        let(:to_location) { nil }
        let(:data) do
          {
            type: 'moves',
            attributes: move_attributes.merge(move_type: nil),
            relationships: {
              person: { data: { type: 'people', id: person.id } },
              from_location: { data: { type: 'locations', id: from_location.id } },
            },
          }
        end

        it_behaves_like 'an endpoint that responds with success 201'

        it 'creates a move', skip_before: true do
          expect { post '/api/v1/moves', params: { data: data }, headers: headers, as: :json }
            .to change(Move, :count).by(1)
        end

        it 'sets the move_type to `prison_recall`' do
          expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'prison_recall'
        end
      end

      context 'with a proposed move' do
        let(:move_attributes) { attributes_for(:move, status: 'proposed') }

        it_behaves_like 'an endpoint that responds with success 201'
      end

      context 'when a court hearing is passed', skip_before: true do
        before do
          allow(Moves::CreateCourtHearings).to receive(:new).and_call_original
        end
        let(:move_attributes) {
          { date: Date.today,
            time_due: Time.now,
            status: 'requested',
            additional_information: 'some more info',
            move_type: 'court_appearance' }
        }

        let(:data) do
          {
            type: 'moves',
            attributes: move_attributes.merge(move_type: nil),
            relationships: {
              person: { data: { type: 'people', id: person.id } },
              from_location: { data: { type: 'locations', id: from_location.id } },
              to_location: { data: { type: 'locations', id: to_location.id } },
              court_hearings: {
                data: [
                  {
                    type: 'court_hearing',
                    attributes: {
                      "start_time": '2018-01-01T18:57Z',
                      "case_start_date": '2018-01-01',
                      "case_number": 'T32423423423',
                      "nomis_case_id": '4232423',
                      "court_type": 'Adult',
                      "comments": 'Witness for Foo Bar',
                    }
                  }
                ]
              },
            },
          }
        end

        context 'when creating a court_hearing in nomis succeeds' do
          it 'returns the hearing in the json body' do
            # expected_court_hearings = {
            #   "start_time": '2018-01-01T18:57Z',
            #   "case_start_date": '2018-01-01',
            #   "case_number": 'T32423423423',
            #   "nomis_case_id": '4232423',
            #   "nomis_hearing_id": '4232424',
            #   "saved_to_nomis": false,
            #   "court_type": 'Adult',
            #   "comments": 'Witness for Foo Bar',
            # }

            post '/api/v1/moves', params: { data: data }, headers: headers, as: :json

            court_hearings_response = response_json['included'].select { |entry| entry['type'] == 'court_hearings' }
            expect(court_hearings_response.count).to be 1
          end

          it 'creates the court hearings', skip_before: true do
            expect { post '/api/v1/moves', params: { data: data }, headers: headers, as: :json }.
              to change { CourtHearing.count }.
              by(1)
          end
        end

        context 'when creating a hearing in nomis fails', skip_before: true do
          before do
            # allow(Move::CourtHearting)
          end

          it 'returns the hearing in the json body' do
            expected_court_hearings = {
              "start_time": '2018-01-01T18:57Z',
              "case_start_date": '2018-01-01',
              "case_number": 'T32423423423',
              "nomis_case_id": '4232423',
              "nomis_hearing_id": nil,
              "saved_to_nomis": false,
              "court_type": 'Adult',
              "comments": 'Witness for Foo Bar',
            }

            post '/api/v1/moves', params: { data: data }, headers: headers, as: :json
            expect(response_json).to include(expected_court_hearings)
          end

          it 'creates a move with a court hearing relationship', skip_before: true do
            post '/api/v1/moves', params: { data: data }, headers: headers, as: :json

            expect(response).to have_http_status(:success)

            expect(response_json['data']['relationships']['court_hearings']).to be_present
          end
        end
      end

      context 'with explicit move_agreed and move_agreed_by' do
        let(:date_from) { Date.yesterday }
        let(:date_to) { Date.tomorrow }
        let(:move_attributes) {
          {
            date: Date.today,
            move_agreed: 'true',
            move_agreed_by: 'John Doe',
            date_from: date_from,
            date_to: date_to,
          }
        }

        it 'sets date_from' do
          expect(response_json.dig('data', 'attributes', 'date_from')).to eq date_from.to_s
          expect(move.date_from).to eq date_from
        end

        it 'sets date_to' do
          expect(response_json.dig('data', 'attributes', 'date_to')).to eq date_to.to_s
          expect(move.date_to).to eq date_to
        end

        it 'sets move_agreed' do
          expect(response_json.dig('data', 'attributes', 'move_agreed')).to eq true
        end

        it 'sets move_agreed_by' do
          expect(response_json.dig('data', 'attributes', 'move_agreed_by')).to eq 'John Doe'
        end
      end

      context 'with explicit `move_type`' do
        let(:move_attributes) { attributes_for(:move, move_type: 'prison_recall') }

        it_behaves_like 'an endpoint that responds with success 201'

        it 'creates a move', skip_before: true do
          expect { post '/api/v1/moves', params: { data: data }, headers: headers, as: :json }
            .to change(Move, :count).by(1)
        end

        it 'sets the move_type to `prison_recall`' do
          expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'prison_recall'
        end
      end
    end

    context 'with a bad request' do
      let(:data) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with a reference to a missing relationship' do
      let(:person) { Person.new }
      let(:detail_404) { "Couldn't find Person without an ID" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with validation errors' do
      let(:move_attributes) { attributes_for(:move).except(:date).merge(status: 'invalid') }

      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => "Date can't be blank",
            'source' => { 'pointer' => '/data/attributes/date' },
            'code' => 'blank',
          },
          {
            'title' => 'Unprocessable entity',
            'detail' => 'Status is not included in the list',
            'source' => { 'pointer' => '/data/attributes/status' },
            'code' => 'inclusion',
          },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422'
    end

    context 'with a duplicate move', :skip_before do
      let(:profile) { create(:profile) }
      let(:person) { profile.person }
      let(:move_attributes) do
        attributes_for(:move).merge(date: old_move.date,
                                    person: person,
                                    from_location: from_location,
                                    to_location: to_location)
      end

      before do
        post '/api/v1/moves', params: { data: data }, headers: headers, as: :json
      end

      context 'when there are multiple cancelled duplicates' do
        let!(:old_move) { create(:move, :cancelled, person: person, from_location: from_location, to_location: to_location) }
        let!(:old_move2) { create(:move, :cancelled, person: person, from_location: from_location, to_location: to_location, date: old_move.date) }

        it_behaves_like 'an endpoint that responds with success 201'
      end

      context 'when duplicate is active' do
        let!(:old_move) { create(:move, person: person, from_location: from_location, to_location: to_location) }
        let(:errors_422) do
          [
            {
              title: 'Unprocessable entity',
              detail: 'Date has already been taken',
              source: { 'pointer' => '/data/attributes/date' },
              code: 'taken',
              meta: { 'existing_id' => old_move.id },
            }.stringify_keys,
          ]
        end

        it_behaves_like 'an endpoint that responds with error 422'
      end
    end
  end
end
