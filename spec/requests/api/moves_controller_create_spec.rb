# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MovesController do
  include ActiveJob::TestHelper

  subject(:post_moves) { post '/api/v1/moves', params: { data: }, headers:, as: :json }

  let(:response_json) { JSON.parse(response.body) }

  describe 'POST /moves' do
    let(:schema) { load_yaml_schema('post_moves_responses.yaml') }

    let(:move_attributes) do
      { date: Time.zone.today,
        time_due: Time.zone.now,
        status: 'requested',
        additional_information: 'some more info',
        move_type: 'court_appearance' }
    end

    let!(:from_location) { create :location, suppliers: [supplier] }
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
          to_location: to_location ? { data: { type: 'locations', id: to_location.id } } : { data: nil },
          documents: { data: [{ type: 'documents', id: document.id }] },
          prison_transfer_reason: { data: { type: 'prison_transfer_reasons', id: reason.id } },
        },
      }
    end
    let(:supplier) { create(:supplier) }
    let(:access_token) { 'spoofed-token' }
    let(:content_type) { ApiController::CONTENT_TYPE }

    let(:headers) do
      {
        'Content-Type' => content_type,
        'Authorization' => "Bearer #{access_token}",
        'Idempotency-Key' => SecureRandom.uuid,
      }
    end

    before do
      allow_any_instance_of(PrometheusMetrics).to receive(:record_move_count) # rubocop:disable RSpec/AnyInstance
    end

    context 'when successful' do
      let(:move) { Move.find_by(from_location_id: from_location.id) }

      before do
        allow(person).to receive(:update_nomis_data)
        allow_any_instance_of(Move).to receive(:person).and_return(person) # rubocop:disable RSpec/AnyInstance
      end

      it_behaves_like 'an endpoint that responds with success 201' do
        before { post_moves }
      end

      it 'creates a move' do
        expect { post_moves }.to change(Move, :count).by(1)
      end

      it 'sets the from_location supplier as the supplier on the move' do
        post_moves
        expect(move.supplier).to eq(supplier)
      end

      it "updates the person's nomis data" do
        post_moves
        expect(person).to have_received(:update_nomis_data).once
      end

      it 'records the move count metric' do
        expect_any_instance_of(PrometheusMetrics).to receive(:record_move_count) # rubocop:disable RSpec/AnyInstance
        post_moves
      end

      context 'with a real access token' do
        let(:application) { create(:application, owner: supplier) }
        let(:access_token) { create(:access_token, application:).token }

        before { post_moves }

        it 'audits the supplier' do
          expect(move.versions.map(&:whodunnit)).to eq([nil])
          expect(move.versions.map(&:supplier_id)).to eq([supplier.id])
        end

        it 'sets the application owner as the supplier on the move' do
          expect(move.supplier).to eq(application.owner)
        end
      end

      it 'associates the documents with the newly created move' do
        post_moves
        expect(move.profile.documents).to eq([document])
      end

      it 'associates a reason with the newly created move' do
        post_moves
        expect(move.prison_transfer_reason).to eq(reason)
      end

      context 'when it includes all supported relationship' do
        before { post_moves }

        it 'returns the correct data' do
          ActiveStorage::Current.url_options = { protocol: 'http', host: 'www.example.com', port: 80 } # This is used in the serializer
          expected_response_json = JSON.parse(MoveSerializer.new(move, include: MoveSerializer::SUPPORTED_RELATIONSHIPS).serializable_hash.to_json)

          # Now, URL is a S3 url (not activestorage) hence it changes everytime we call the endpoint
          # The following updates the URL matcher for all the documents
          expected_response_json['included']
              .select { |e| e['type'] == 'documents' }
              .each { |e| e['attributes']['url'] = start_with('http://www.example.com/') }

          expect(response_json).to include_json(expected_response_json)
        end
      end

      it 'does not provide a default value for move_agreed' do
        post_moves
        expect(response_json.dig('data', 'attributes', 'move_agreed')).to eq nil
      end

      it 'sets the additional_information' do
        post_moves
        expect(response_json.dig('data', 'attributes', 'additional_information')).to match 'some more info'
      end

      context 'when the supplier has a webhook subscription' do
        let!(:subscription) { create(:subscription, :no_email_address, supplier:) }
        let!(:notification_type_webhook) { create(:notification_type, :webhook) }
        let(:notification) { subscription.notifications.last }
        let(:faraday_client) do
          class_double(
            Faraday,
            headers: {},
            post:
            instance_double(Faraday::Response, success?: true, status: 202),
          )
        end

        before do
          allow(Faraday).to receive(:new).and_return(faraday_client)
          perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
            post_moves
          end
        end

        it 'has correct attributes' do
          expect(notification).to have_attributes(
            delivered_at: a_value,
            topic: move,
            notification_type: notification_type_webhook,
            event_type: 'create_move',
            response_id: nil,
          )
        end
      end

      context 'when the supplier has an email subscription' do
        let!(:subscription) { create(:subscription, :no_callback_url, supplier:) }
        let!(:notification_type_email) { create(:notification_type, :email) }
        let(:notification) { subscription.notifications.last }
        let(:notify_response) do
          instance_double(
            ActionMailer::MessageDelivery,
            deliver_now!:
                          instance_double(
                            Mail::Message,
                            govuk_notify_response:
                                              instance_double(Notifications::Client::ResponseNotification, id: response_id),
                          ),
          )
        end
        let(:response_id) { SecureRandom.uuid }

        before do
          allow(MoveMailer).to receive(:notify).and_return(notify_response)
          perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyEmailJob]) do
            post_moves
          end
        end

        it 'has correct attributes' do
          expect(notification).to have_attributes(
            delivered_at: a_value,
            topic: move,
            notification_type: notification_type_email,
            event_type: 'create_move',
            response_id:,
          )
        end
      end

      context 'without a `to_location`' do
        let(:from_location) { create :location, :police, suppliers: [supplier] }
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

        it_behaves_like 'an endpoint that responds with success 201' do
          before { post_moves }
        end

        it 'creates a move' do
          expect { post_moves }.to change(Move, :count).by(1)
        end

        it 'sets the move_type to `prison_recall`' do
          post_moves
          expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'prison_recall'
        end
      end

      context 'with a proposed move' do
        let(:move_attributes) { attributes_for(:move).except(:date).merge(status: 'proposed') }

        before { post_moves }

        it_behaves_like 'an endpoint that responds with success 201'
      end

      context 'when a court hearing relationship is passed' do
        let(:court_hearing) { create(:court_hearing) }

        let(:data) do
          {
            type: 'moves',
            attributes: {
              date: Time.zone.today,
              time_due: Time.zone.now,
              status: 'requested',
              additional_information: 'some more info',
              move_type: nil,
            },
            relationships: {
              person: { data: { type: 'people', id: person.id } },
              from_location: { data: { type: 'locations', id: from_location.id } },
              to_location: { data: { type: 'locations', id: to_location.id } },
              court_hearings: { data: [{ type: 'court_hearings', id: court_hearing.id }] },
            },
          }
        end

        it 'returns the hearing in the json body' do
          post_moves

          court_hearings_response = response_json['included'].select { |entry| entry['type'] == 'court_hearings' }
          expect(court_hearings_response.count).to be 1
        end
      end

      context 'with explicit move_agreed and move_agreed_by' do
        let(:date_from) { Date.yesterday }
        let(:date_to) { Date.tomorrow }
        let(:move_attributes) do
          {
            date: Time.zone.today,
            move_agreed: 'true',
            move_agreed_by: 'John Doe',
            date_from:,
            date_to:,
          }
        end

        before { post_moves }

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

      context 'with explicit court_other `move_type`' do
        let(:move_attributes) { attributes_for(:move, move_type: 'court_other') }
        let(:to_location) { create :location, :high_security_hospital, suppliers: [supplier] }

        it_behaves_like 'an endpoint that responds with success 201' do
          before { post_moves }
        end

        it 'creates a move' do
          expect { post_moves }.to change(Move, :count).by(1)
        end

        it 'sets the move_type to `court_other`' do
          post_moves
          expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'court_other'
        end
      end

      context 'with explicit hospital `move_type`' do
        let(:move_attributes) { attributes_for(:move, move_type: 'hospital') }
        let(:to_location) { create :location, :high_security_hospital, suppliers: [supplier] }

        it_behaves_like 'an endpoint that responds with success 201' do
          before { post_moves }
        end

        it 'creates a move' do
          expect { post_moves }.to change(Move, :count).by(1)
        end

        it 'sets the move_type to `hospital`' do
          post_moves
          expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'hospital'
        end
      end

      context 'with explicit prison_remand `move_type`' do
        let(:move_attributes) { attributes_for(:move, move_type: 'prison_remand') }
        let(:to_location) { create :location, :stc, suppliers: [supplier] }

        it_behaves_like 'an endpoint that responds with success 201' do
          before { post_moves }
        end

        it 'creates a move' do
          expect { post_moves }.to change(Move, :count).by(1)
        end

        it 'sets the move_type to `prison_remand`' do
          post_moves
          expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'prison_remand'
        end
      end

      context 'with explicit video_remand `move_type`' do
        let(:move_attributes) { attributes_for(:move, move_type: 'video_remand') }
        let(:from_location) { create :location, :police, suppliers: [supplier] }
        let(:to_location) { nil }

        it_behaves_like 'an endpoint that responds with success 201' do
          before { post_moves }
        end

        it 'creates a move' do
          expect { post_moves }.to change(Move, :count).by(1)
        end

        it 'sets the move_type to `video_remand`' do
          post_moves
          expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'video_remand'
        end
      end

      context 'with a profile relationship' do
        let(:profile) { create(:profile) }
        let(:data) do
          {
            type: 'moves',
            attributes: move_attributes,
            relationships: {
              profile: { data: { type: 'profiles', id: profile.id } },
              from_location: { data: { type: 'locations', id: from_location.id } },
              to_location: to_location ? { data: { type: 'locations', id: to_location.id } } : nil,
              documents: { data: [{ type: 'documents', id: document.id }] },
              prison_transfer_reason: { data: { type: 'prison_transfer_reasons', id: reason.id } },
            },
          }
        end

        before { post_moves }

        it 'associates the profile with the newly created move' do
          expect(move.profile).to eq(profile)
        end

        it 'returns the profile in the response' do
          expected_response = { 'type' => 'profiles', 'id' => profile.id }

          expect(response_json.dig('data', 'relationships', 'profile', 'data')).to eq(expected_response)
        end

        it 'returns the profile person in the response' do
          expected_response = { 'type' => 'people', 'id' => profile.person.id }

          expect(response_json.dig('data', 'relationships', 'person', 'data')).to eq(expected_response)
        end
      end

      # TODO: Remove when people/profiles migration is completed
      context 'with a profile and person relationship' do
        let(:person) { create(:person) }
        let(:profile) { create(:profile) }

        let(:data) do
          {
            type: 'moves',
            attributes: move_attributes,
            relationships: {
              profile: { data: { type: 'profiles', id: profile.id } },
              person: { data: { type: 'people', id: person.id } },
              from_location: { data: { type: 'locations', id: from_location.id } },
              to_location: to_location ? { data: { type: 'locations', id: to_location.id } } : nil,
              documents: { data: [{ type: 'documents', id: document.id }] },
              prison_transfer_reason: { data: { type: 'prison_transfer_reasons', id: reason.id } },
            },
          }
        end

        before { post_moves }

        it 'favours the profile passed in with the newly created move' do
          expect(move.profile).to eq(profile)
        end

        it 'returns the profile person in the response' do
          expected_response = { 'type' => 'people', 'id' => profile.person.id }

          expect(response_json.dig('data', 'relationships', 'person', 'data')).to eq(expected_response)
        end
      end
    end

    context 'with a bad request' do
      let(:data) { nil }

      before { post_moves }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with a reference to a missing relationship' do
      let(:from_location) { build(:location) }
      let(:detail_404) { "Couldn't find Location without an ID" }

      before { post_moves }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with invalid status errors' do
      let(:move_attributes) { attributes_for(:move).merge(status: 'invalid') }

      let(:errors_422) do
        [
          {
            'title' => 'Invalid status',
            'detail' => /Status is not included in the list/,
          },
        ]
      end

      before { post_moves }

      it_behaves_like 'an endpoint that responds with error 422'
    end

    context 'with missing date' do
      let(:move_attributes) { attributes_for(:move).except(:date) }

      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable content',
            'detail' => "Date can't be blank",
            'source' => { 'pointer' => '/data/attributes/date' },
            'code' => 'blank',
          },
        ]
      end

      before { post_moves }

      it_behaves_like 'an endpoint that responds with error 422'
    end
  end
end
