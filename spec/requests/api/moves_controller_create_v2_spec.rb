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
    JSON.parse(V2::MoveSerializer.new(move).serializable_hash.to_json)
  end

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
      'X-Current-User' => 'TEST_USER',
    }
  end

  describe 'POST /moves' do
    let(:move_attributes) do
      {
        date: Date.today,
        time_due: Time.zone.now,
        status: status,
        additional_information: 'some more info',
        move_type: 'court_appearance',
      }
    end

    let(:status) { 'requested' }
    let(:profile) { create(:profile) }
    let(:person) { create(:person) }
    let(:another_supplier) { create(:supplier) }
    let(:from_location) { create :location, suppliers: [another_supplier] }
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

    before do
      allow(person).to receive(:update_nomis_data)
      allow_any_instance_of(Move).to receive(:person).and_return(person) # rubocop:disable RSpec/AnyInstance
    end

    it_behaves_like 'an endpoint that responds with success 201' do
      before { do_post }
    end

    it 'creates a move' do
      expect { do_post }.to change(Move, :count).by(1)
    end

    it 'creates a GenericEvent without a supplier' do
      do_post
      expect(GenericEvent.last.supplier).to be(nil)
    end

    it 'sets the created by on the GenericEvent' do
      do_post

      expect(GenericEvent.last.created_by).to eq('TEST_USER')
    end

    it "updates the person's nomis data" do
      do_post
      expect(person).to have_received(:update_nomis_data).once
    end

    context 'when the new move status is `proposed`' do
      before do
        move_attributes[:date_from] = Date.today.iso8601
      end

      let(:status) { 'proposed' }

      it 'creates a MoveProposed event' do
        expect { do_post }.to change(GenericEvent::MoveProposed, :count).by(1)
      end
    end

    context 'when the new move status is `requested`' do
      let(:status) { 'requested' }

      it 'creates a MoveRequested event' do
        expect { do_post }.to change(GenericEvent::MoveRequested, :count).by(1)
      end
    end

    context 'when the new move status is `cancelled`' do
      let(:status) { 'cancelled' }

      it 'does not create any new events' do
        expect { do_post }.not_to change(GenericEvent, :count)
      end
    end

    it 'sets the from_location supplier as the supplier on the move' do
      do_post

      expect(move.supplier).to eq(another_supplier)
    end

    context 'with a real access token' do
      let(:application) { create(:application, owner: supplier) }
      let(:access_token) { create(:access_token, application: application).token }

      it 'audits the supplier' do
        do_post

        expect(move.versions.map(&:whodunnit)).to eq(%w[TEST_USER])
        expect(move.versions.map(&:supplier_id)).to eq([supplier.id])
      end

      it 'sets the application owner as the supplier on the move' do
        do_post

        expect(move.supplier).to eq(application.owner)
      end

      it 'creates a GenericEvent with a supplier' do
        do_post
        expect(GenericEvent::MoveRequested.last.supplier).to be_a(Supplier)
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

      let!(:subscription) { create(:subscription, :no_email_address, supplier: another_supplier) }

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

      context 'with a requested move' do
        it 'creates the correct notification' do
          perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
            do_post
          end

          expect(subscription.notifications.last.attributes).to include_json(expected_notification_attributes)
        end
      end

      context 'with a proposed move' do
        let(:move_attributes) { attributes_for(:move).except(:date).merge(move_type: 'court_appearance', status: 'proposed') }

        it 'creates the correct notification' do
          perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
            do_post
          end

          expect(subscription.notifications.last).to be_nil
        end
      end
    end

    context 'when the supplier has an email subscription' do
      let!(:subscription) { create(:subscription, :no_callback_url, supplier: another_supplier) }
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
      let(:from_location) { create :location, :police, suppliers: [another_supplier] }
      let(:to_location) { nil }
      let(:data) do
        {
          type: 'moves',
          attributes: move_attributes.merge(move_type: 'prison_recall'),
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
        expect { do_post }.to change(Move, :count).by(1)
      end

      it 'sets the move_type to `prison_recall`' do
        do_post

        expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'prison_recall'
      end
    end

    context 'with a proposed move' do
      let(:move_attributes) { attributes_for(:move).except(:date).merge(move_type: 'court_appearance', status: 'proposed') }

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
            time_due: Time.zone.now,
            status: 'requested',
            additional_information: 'some more info',
            move_type: 'court_appearance',
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
          move_type: 'court_appearance',
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

    context 'with explicit court_other `move_type`' do
      let(:move_attributes) { attributes_for(:move, move_type: 'court_other') }
      let(:to_location) { create :location, :high_security_hospital, suppliers: [supplier] }

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end

      it 'creates a move' do
        expect { do_post }.to change(Move, :count).by(1)
      end

      it 'sets the move_type to `court_other`' do
        do_post

        expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'court_other'
      end
    end

    context 'with explicit hospital `move_type`' do
      let(:move_attributes) { attributes_for(:move, move_type: 'hospital') }
      let(:to_location) { create :location, :high_security_hospital, suppliers: [supplier] }

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end

      it 'creates a move' do
        expect { do_post }.to change(Move, :count).by(1)
      end

      it 'sets the move_type to `hospital`' do
        do_post

        expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'hospital'
      end
    end

    context 'with explicit prison_remand `move_type`' do
      let(:move_attributes) { attributes_for(:move, move_type: 'prison_remand') }
      let(:to_location) { create :location, :stc, suppliers: [supplier] }

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end

      it 'creates a move' do
        expect { do_post }.to change(Move, :count).by(1)
      end

      it 'sets the move_type to `prison_remand`' do
        do_post

        expect(response_json.dig('data', 'attributes', 'move_type')).to eq 'prison_remand'
      end
    end

    context 'with explicit video_remand `move_type`' do
      let(:move_attributes) { attributes_for(:move, move_type: 'video_remand') }
      let(:from_location) { create :location, :police, suppliers: [supplier] }
      let(:to_location) { nil }

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end

      it 'creates a move' do
        expect { do_post }.to change(Move, :count).by(1)
      end

      it 'sets the move_type to `video_remand`' do
        do_post

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

      let(:detail_404) { "Couldn't find Location with 'id'=foo" }

      it_behaves_like 'an endpoint that responds with error 404' do
        before { do_post }
      end
    end

    context 'when omitting move_type attribute' do
      let(:move_attributes) { attributes_for(:move).except(:move_type) }

      let(:errors_422) do
        [
          { 'title' => 'Unprocessable entity', 'detail' => 'Move type is not included in the list', 'source' => { 'pointer' => '/data/attributes/move_type' }, 'code' => 'inclusion' },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_post }
      end
    end

    context 'when specifying an invalid status' do
      let(:move_attributes) { attributes_for(:move).merge(move_type: 'court_appearance', status: 'INVALID') }

      let(:errors_422) do
        [
          { 'title' => 'Invalid status', 'detail' => /Status is not included in the list/ },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_post }
      end
    end

    context 'when missing a required attribute' do
      let(:move_attributes) { attributes_for(:move).except(:date).merge(move_type: 'court_appearance', status: 'requested') }

      let(:errors_422) do
        [
          { 'title' => 'Unprocessable entity', 'detail' => "Date can't be blank", 'source' => { 'pointer' => '/data/attributes/date' }, 'code' => 'blank' },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_post }
      end
    end

    context 'when no attributes specified' do
      let(:move_attributes) { nil }
      let(:errors_422) do
        [
          { 'title' => 'Unprocessable entity', 'detail' => 'Supplier must exist', 'source' => { 'pointer' => '/data/attributes/supplier' }, 'code' => 'blank' },
          { 'title' => 'Unprocessable entity', 'detail' => 'Move type is not included in the list', 'source' => { 'pointer' => '/data/attributes/move_type' }, 'code' => 'inclusion' },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_post }
      end
    end

    context 'when no attributes or relationships specified' do
      let(:data) { { type: 'moves' } }
      let(:errors_422) do
        [
          { 'title' => 'Unprocessable entity', 'detail' => 'Supplier must exist', 'source' => { 'pointer' => '/data/attributes/supplier' }, 'code' => 'blank' },
          { 'title' => 'Unprocessable entity', 'detail' => 'From location must exist', 'source' => { 'pointer' => '/data/attributes/from_location' }, 'code' => 'blank' },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_post }
      end
    end

    context 'when a move is a duplicate' do
      let(:move_attributes) { attributes_for(:move).merge(move_type: 'court_appearance', date: move.date) }

      context 'when there are cancelled duplicates' do
        let!(:move) { create(:move, :cancelled, :court_appearance, profile: profile, from_location: from_location, to_location: to_location) }

        it_behaves_like 'an endpoint that responds with success 201' do
          before { do_post }
        end
      end

      context 'when the Move has been already created' do
        let!(:move) { create(:move, :court_appearance, profile: profile, from_location: from_location, to_location: to_location) }
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

    context 'when the move is to an inactive location' do
      let(:to_location) { create :location, :court, :inactive }
      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => 'To location must be an active location',
            'source' => { 'pointer' => '/data/attributes/to_location' },
            'code' => 'inactive_location',
          },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_post }
      end
    end

    context 'when the profile has no prisoner category' do
      let(:profile) { create(:profile, category: nil) }

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end
    end

    context 'when the profile is for an unsupported prisoner category' do
      let(:profile) { create(:profile, :category_not_supported) }
      let(:category_key) { profile.category.key.humanize.downcase }
      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => "Profile person is a category '#{category_key}' prisoner and cannot be moved using this service",
            'source' => { 'pointer' => '/data/attributes/profile' },
            'code' => 'unsupported_prisoner_category',
          },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_post }
      end
    end

    context 'when the profile is for a supported prisoner category' do
      let(:profile) { create(:profile, :category_supported) }

      it_behaves_like 'an endpoint that responds with success 201' do
        before { do_post }
      end
    end
  end

  def do_post
    post '/api/moves', params: { data: data }, headers: headers, as: :json
  end
end
