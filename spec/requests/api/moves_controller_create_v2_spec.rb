# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MovesController do
  include ActiveJob::TestHelper

  let(:response_json) { JSON.parse(response.body) }
  let(:schema) { load_yaml_schema('post_moves_responses.yaml', version: 'v2') }
  let(:supplier) { create(:supplier) }
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }

  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: move, serializer: V2::MoveSerializer))
  end

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
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

    let(:profile) { create(:profile) }
    let(:from_location) { create :location, suppliers: [supplier] }
    let(:to_location) { create :location, :court }
    let(:reason) { create(:prison_transfer_reason) }
    let(:data) do
      {
        type: 'moves',
        attributes: move_attributes,
        relationships: {
          profile: { data: { type: 'profiles', id: profile.id } },
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

    context 'with a real access token' do
      let(:application) { create(:application, owner_id: supplier.id) }
      let(:access_token) { create(:access_token, application: application).token }

      it 'audits the supplier' do
        do_post

        expect(move.versions.map(&:whodunnit)).to eq([supplier.id])
      end
    end

    it 'associates a reason with the newly created move' do
      do_post

      expect(move.prison_transfer_reason).to eq(reason)
    end

    it 'returns serialized data' do
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

    context 'when the supplier has a webhook subscription' do
      before do
        create(:notification_type, :webhook)
        allow(Faraday).to receive(:new).and_return(faraday_client)
      end

      let!(:subscription) { create(:subscription, :no_email_address, supplier: supplier) }

      let(:faraday_client) do
        class_double(
          Faraday,
          headers: {},
          post: instance_double(Faraday::Response, success?: true, status: 202),
        )
      end

      let(:expected_notification_attributes) do
        {
          'event_type' => 'create_move',
          'topic_id' => move.id,
          'topic_type' => 'Move',
          'delivery_attempts' => 1,
          'delivery_attempted_at' => be_within(5.seconds).of(Time.zone.now),
          'delivered_at' => be_within(5.seconds).of(Time.zone.now),
          'discarded_at' => nil,
          'response_id' => nil,
          'notification_type_id' => 'webhook',
        }
      end

      it 'creates the correct notification' do
        perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
          do_post
        end

        expect(subscription.notifications.last.attributes).to include_json(expected_notification_attributes)
      end
    end

    context 'when the supplier has an email subscription' do
      let!(:subscription) { create(:subscription, :no_callback_url, supplier: supplier) }
      let(:expected_notification_attributes) do
        {
          'event_type' => 'create_move',
          'topic_id' => move.id,
          'topic_type' => 'Move',
          'delivery_attempts' => 0,
          'delivery_attempted_at' => nil,
          'delivered_at' => nil,
          'discarded_at' => nil,
          'response_id' => nil,
          'notification_type_id' => 'email',
        }
      end
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

      it 'creates the correct notification' do
        create(:notification_type, :email)
        allow(MoveMailer).to receive(:notify).and_return(notify_response)

        perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
          do_post
        end

        expect(subscription.notifications.last.attributes).to include_json(expected_notification_attributes)
      end
    end

    context 'without a `to_location`' do
      let(:to_location) { nil }
      let(:data) do
        {
          type: 'moves',
          attributes: move_attributes.merge(move_type: nil),
          relationships: {
            profile: { data: { type: 'profiles', id: profile.id } },
            from_location: { data: { type: 'locations', id: from_location.id } },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end

      it 'creates a move' do
        expect { do_post } .to change(Move, :count).by(1)
      end

      it 'sets the move_type to `prison_recall`' do
        do_post

        expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'prison_recall'
      end
    end

    context 'with a proposed move' do
      let(:move_attributes) { attributes_for(:move).except(:date).merge(status: 'proposed') }

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end
    end

    context 'when a court hearing relationship is passed' do
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
            profile: { data: { type: 'profiles', id: profile.id } },
            from_location: { data: { type: 'locations', id: from_location.id } },
            to_location: { data: { type: 'locations', id: to_location.id } },
            court_hearings: { data: [{ type: 'court_hearings', id: court_hearing.id }] },
          },
        }
      end

      it 'associates the court hearing with the `Move`' do
        do_post

        expect(Move.last.court_hearings).to eq([court_hearing])
      end
    end

    context 'with explicit move_agreed and move_agreed_by' do
      before { do_post }

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
      let(:move_attributes) { attributes_for(:move, move_type: 'video_remand_hearing') }
      let(:from_location) { create :location, :police, suppliers: [supplier] }
      let(:to_location) { nil }

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end

      it 'creates a move' do
        expect { do_post }.to change(Move, :count).by(1)
      end

      it 'sets the move_type to `video_remand_hearing`' do
        do_post

        expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'video_remand_hearing'
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
    end

    context 'when the params are not valid' do
      let(:data) { nil }

      it_behaves_like 'an endpoint that responds with error 400' do
        before { do_post }
      end
    end

    context 'when supplying a reference to a non-existent relationship' do
      let(:data) do
        {
          type: 'moves',
          attributes: move_attributes,
          relationships: {
            profile: { data: { type: 'profiles', id: profile.id } },
            from_location: { data: { type: 'locations', id: 'foo' } },
            to_location: to_location ? { data: { type: 'locations', id: to_location.id } } : nil,
            prison_transfer_reason: { data: { type: 'prison_transfer_reasons', id: reason.id } },
          },
        }
      end

      let(:detail_404) {  "Couldn't find Location with 'id'=foo" }

      it_behaves_like 'an endpoint that responds with error 404' do
        before { do_post }
      end
    end

    context 'when specifying invalid attributes' do
      let(:move_attributes) { attributes_for(:move).except(:date).merge(status: 'invalid') }

      let(:errors_422) do
        [
          { 'title' => 'Unprocessable entity', 'detail' => "Date can't be blank", 'source' => { 'pointer' => '/data/attributes/date' }, 'code' => 'blank' },
          { 'title' => 'Unprocessable entity', 'detail' => 'Status is not included in the list', 'source' => { 'pointer' => '/data/attributes/status' }, 'code' => 'inclusion' },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_post }
      end
    end

    context 'when a move is a duplicate' do
      let(:move_attributes) { attributes_for(:move).merge(date: move.date) }

      context 'when there are cancelled duplicates' do
        let!(:move) { create(:move, :cancelled, profile: profile, from_location: from_location, to_location: to_location) }

        it_behaves_like 'an endpoint that responds with success 201' do
          before { do_post }
        end
      end

      context 'when the Move has been already created' do
        let!(:move) { create(:move, profile: profile, from_location: from_location, to_location: to_location) }
        let(:errors_422) do
          [
            {
              'title' => 'Unprocessable entity',
              'detail' => 'Date has already been taken',
              'source' => { 'pointer' => '/data/attributes/date' },
              'code' => 'taken',
              'meta' => { 'existing_id' => move.id },
            },
          ]
        end

        it_behaves_like 'an endpoint that responds with error 422' do
          before { do_post }
        end
      end
    end
  end

  def do_post
    post '/api/moves', params: { data: data }, headers: headers, as: :json
  end
end
