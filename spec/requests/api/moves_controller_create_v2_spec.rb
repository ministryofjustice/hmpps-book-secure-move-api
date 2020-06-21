# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MovesController do
  include ActiveJob::TestHelper

  let(:response_json) { JSON.parse(response.body) }
  let(:schema) { load_yaml_schema('post_moves_responses.yaml', version: 'v2') }
  let(:supplier) { create(:supplier) }
  let(:application) { create(:application, owner_id: supplier.id) }
  let(:access_token) { create(:access_token, application: application).token }
  let(:content_type) { ApiController::CONTENT_TYPE }

  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: move, include: MoveSerializer::SUPPORTED_RELATIONSHIPS))
  end

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'POST /moves' do
    let(:move_attributes) do
      {
        date: Date.today,
        time_due: Time.now,
        status: 'requested',
        additional_information: 'some more info',
        move_type: 'court_appearance',
      }
    end

    let(:from_location) { create :location, location_type: :prison, suppliers: [supplier] }
    let(:to_location) { create :location, :court }
    let(:reason) { create(:prison_transfer_reason) }
    let(:data) do
      {
        type: 'moves',
        attributes: move_attributes,
        relationships: {
          from_location: { data: { type: 'locations', id: from_location.id } },
          to_location: to_location ? { data: { type: 'locations', id: to_location.id } } : { data: nil },
          prison_transfer_reason: { data: { type: 'prison_transfer_reasons', id: reason.id } },
        },
      }
    end

    let(:move) { Move.find_by(from_location_id: from_location.id) }

    it_behaves_like 'an endpoint that responds with success 201' do
      before { do_post }
    end

    it 'creates a move' do
      expect { do_post } .to change(Move, :count).by(1)
    end

    it 'audits the supplier' do
      do_post

      expect(move.versions.map(&:whodunnit)).to eq([supplier.id])
    end

    it 'associates a reason with the newly created move' do
      do_post

      expect(move.prison_transfer_reason).to eq(reason)
    end

    it 'returns the correct data' do
      do_post

      expect(response_json).to eq resource_to_json
    end

    it 'does not provide a default value for move_agreed' do
      do_post

      expect(response_json.dig('data', 'attributes', 'move_agreed')).to eq nil
    end

    it 'sets the additional_information' do
      do_post

      expect(response_json.dig('data', 'attributes', 'additional_information')).to match 'some more info'
    end

    context 'when the supplier has a webhook subscription', :skip_before do
      let!(:subscription) { create(:subscription, :no_email_address, supplier: supplier) }
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
          post '/api/moves', params: { data: data }, headers: headers, as: :json
        end
      end

      describe 'notification record' do
        let(:expected_notification_attributes) do
          {
            'delivered_at' => be_present,
            'topic' => move,
            'notification_type' => notification_type_webhook,
            'event_type' => 'create_move',
            'response_id' => be_nil,
          }
        end

        it 'creates the correct notification' do
          do_post
          actual_notifcation_attributes = notification.attributes.slice(
            'delivered_at',
            'topic',
            'notification_type',
            'event_type',
            'response_id',
          )

          expect(expected_notification_attributes).to eq(actual_notifcation_attributes)
        end

        it { expect(delivered_at).not_to be_nil }
        it { expect(topic).to eql(move) }
        it { expect(notification_type).to eql(notification_type_webhook) }
        it { expect(event_type).to eql('create_move') }
        it { expect(response_id).to be_nil }
      end
    end

    context 'when the supplier has an email subscription', :skip_before do
      let!(:subscription) { create(:subscription, :no_callback_url, supplier: supplier) }
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
          post '/api/moves', params: { data: data }, headers: headers, as: :json
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
        expect { post '/api/moves', params: { data: data }, headers: headers, as: :json }
          .to change(Move, :count).by(1)
      end

      it 'sets the move_type to `prison_recall`' do
        expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'prison_recall'
      end
    end

    context 'with a proposed move' do
      let(:move_attributes) { attributes_for(:move).except(:date).merge(status: 'proposed') }

      it_behaves_like 'an endpoint that responds with success 201'
    end

    context 'when a court hearing relationship is passed', skip_before: true do
      let(:court_hearing) { create(:court_hearing) }

      let(:data) do
        {
          type: 'moves',
          attributes: {
            date: Date.today,
            time_due: Time.now,
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
        post '/api/moves', params: { data: data }, headers: headers, as: :json

        court_hearings_response = response_json['included'].select { |entry| entry['type'] == 'court_hearings' }
        expect(court_hearings_response.count).to be 1
      end
    end

    context 'with explicit move_agreed and move_agreed_by' do
      let(:date_from) { Date.yesterday }
      let(:date_to) { Date.tomorrow }
      let(:move_attributes) do
        {
          date: Date.today,
          move_agreed: 'true',
          move_agreed_by: 'John Doe',
          date_from: date_from,
          date_to: date_to,
        }
      end

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

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end

      it 'creates a move' do
        expect { do_post }.to change(Move, :count).by(1)
      end

      it 'sets the move_type to `prison_recall`' do
        do_post

        expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'prison_recall'
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
            prison_transfer_reason: { data: { type: 'prison_transfer_reasons', id: reason.id } },
          },
        }
      end

      it 'associates the profile with the newly created move' do
        do_post

        expect(move.profile).to eq(profile)
      end

      it 'returns the profile in the response' do
        do_post

        expected_response = { 'type' => 'profiles', 'id' => profile.id }

        expect(response_json.dig('data', 'relationships', 'profile', 'data')).to eq(expected_response)
      end

      it 'returns the profile person in the response' do
        do_post

        expected_response = { 'type' => 'people', 'id' => profile.person.id }

        expect(response_json.dig('data', 'relationships', 'person', 'data')).to eq(expected_response)
      end
    end

    context 'when not authorized', :skip_before, :with_invalid_auth_headers do
      let(:headers) { {} }
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401' do
        before { do_post }
      end
    end

    context 'when the CONTENT_TYPE header is invalid' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415' do
        before { do_post }
      end
    end

    context 'when the params are not valid' do
      let(:data) { nil }

      it_behaves_like 'an endpoint that responds with error 400' do
        before { do_post }
      end
    end

    context 'when supplying a reference to a missing relationship' do
      let(:from_location) { build(:location) }
      let(:detail_404) { "Couldn't find Location without an ID" }

      it_behaves_like 'an endpoint that responds with error 404' do
        before { do_post }
      end
    end

    context 'when specifying invalid attributes' do
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

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_post }
      end
    end

    context 'with a duplicate move', :skip_before do
      let(:profile) { create(:profile) }
      let(:person) { profile.person }
      let(:move_attributes) do
        attributes_for(:move).merge(
          date: old_move.date,
          person: profile.person,
          from_location: from_location,
          to_location: to_location,
        )
      end

      before do
        post '/api/moves', params: { data: data }, headers: headers, as: :json
      end

      context 'when there are multiple cancelled duplicates' do
        let!(:old_move) { create(:move, :cancelled, profile: person.latest_profile, from_location: from_location, to_location: to_location) }
        let!(:old_move2) { create(:move, :cancelled, profile: person.latest_profile, from_location: from_location, to_location: to_location, date: old_move.date) }

        it_behaves_like 'an endpoint that responds with success 201'
      end

      context 'when duplicate is active' do
        let!(:old_move) { create(:move, profile: person.latest_profile, from_location: from_location, to_location: to_location) }
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

  def do_post
    post '/api/moves', params: { data: data }, headers: headers, as: :json
  end
end
