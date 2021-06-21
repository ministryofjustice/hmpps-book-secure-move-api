# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MovesController do
  include ActiveJob::TestHelper

  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }
  let(:schema) { load_yaml_schema('patch_move_responses.yaml', version: 'v2') }
  let(:access_token) { 'spoofed-token' }
  let(:supplier) { create(:supplier) }

  let(:resource_to_json) do
    JSON.parse(V2::MoveSerializer.new(move.reload, serializer: V2::MoveSerializer).serializable_hash.to_json)
  end

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'PATCH /moves' do
    let!(:move) { create :move, :proposed, :prison_recall, from_location: from_location, profile: profile, supplier: supplier }

    let(:from_location) { create :location, :police, suppliers: [supplier] }
    let(:move_id) { move.id }
    let(:profile) { create(:profile) }
    let(:date_from) { Date.yesterday }
    let(:date_to) { Date.tomorrow }

    let(:move_params) do
      {
        type: 'moves',
        attributes: {
          status: 'requested',
          additional_information: 'some more info',
          cancellation_reason: nil,
          cancellation_reason_comment: nil,
          move_agreed: true,
          move_agreed_by: 'Fred Bloggs',
          date_from: date_from,
          date_to: date_to,
        },
      }
    end
    let(:patch_params) { { data: move_params } }

    let(:expected_attributes) do
      {
        'additional_information' => 'some more info',
        'cancellation_reason' => nil,
        'cancellation_reason_comment' => nil,
        'date_from' => date_from,
        'date_to' => date_to,
        'move_agreed' => true,
        'move_agreed_by' => 'Fred Bloggs',
        'status' => 'requested',
      }
    end

    it 'updates the specified attributes of a `Move`' do
      do_patch

      actual_attributes = move.reload.attributes
      expect(actual_attributes).to include(expected_attributes)
    end

    it 'returns serialized data' do
      do_patch
      expect(response_json).to eq resource_to_json
    end

    it_behaves_like 'an endpoint that responds with success 200' do
      before { do_patch }
    end

    context 'when move is associated to an allocation' do
      let!(:move) { create :move, :with_allocation, profile: profile }
      let(:move_params) do
        {
          type: 'moves',
          attributes: {
            status: 'cancelled',
            cancellation_reason: 'other',
          },
        }
      end

      before do
        allow(Allocations::CreateInNomis).to receive(:call)
      end

      it 'updates the allocation status to unfilled' do
        expect(move.reload.allocation).to be_unfilled
      end

      context 'when linking a profile' do
        let!(:move) { create :move, :with_allocation, profile: nil }
        let(:profile) { create(:profile) }
        let(:move_params) do
          {
            type: 'moves',
            attributes: {
              status: 'requested',
            },
            relationships: { profile: { data: { id: profile.id, type: 'profiles' } } },
          }
        end

        it 'updates the allocation status to filled' do
          do_patch

          expect(move.reload.allocation).to be_filled
        end
      end

      context 'when unlinking a profile' do
        let(:profile) { create(:profile) }
        let!(:move) { create :move, :with_allocation, profile: profile }
        let(:move_params) do
          {
            type: 'moves',
            attributes: {
              status: 'requested',
            },
            relationships: { profile: { data: nil } },
          }
        end

        it 'updates the allocation status to unfilled' do
          do_patch

          expect(move.reload.allocation).to be_unfilled
        end
      end

      context 'when create_in_nomis param is true' do
        let(:patch_params) { { data: move_params, create_in_nomis: true } }

        it 'creates a prison transfer event in Nomis' do
          do_patch

          expect(Allocations::CreateInNomis).to have_received(:call).with(move)
        end
      end

      context 'when create_in_nomis param is false' do
        let(:patch_params) { { data: move_params, create_in_nomis: false } }

        it 'does not create a prison transfer event in Nomis' do
          do_patch

          expect(Allocations::CreateInNomis).not_to have_received(:call).with(move)
        end
      end
    end

    context 'when changing a moves profile' do
      let(:after_profile) { create(:profile) }
      let(:move_params) do
        {
          type: 'moves',
          attributes: {
            status: 'requested',
          },
          relationships: { profile: { data: { id: after_profile.id, type: 'profiles' } } },
        }
      end

      it 'updates the moves profile' do
        do_patch

        expect(move.reload.profile).to eq(after_profile)
      end

      it 'does not affect other relationships' do
        expect { do_patch }.not_to change { move.reload.from_location }
      end

      it 'returns the updated profile in the response body' do
        do_patch

        profile_ids = response_json.dig('data', 'relationships', 'profile', 'data', 'id')

        expect(profile_ids).to eq(after_profile.id)
      end

      context 'when profile is nil' do
        let(:move_params) do
          {
            type: 'moves',
            attributes: {
              status: 'requested',
            },
            relationships: { profile: { data: nil } },
          }
        end

        it 'unlinks profile from the move' do
          do_patch

          expect(move.reload.profile).to be_nil
        end
      end
    end

    context 'when trying to update from_location and to_location' do
      let(:new_from_location) { create :location }
      let(:new_to_location) { create :location }

      let(:move_params) do
        {
          type: 'moves',
          attributes: {
            status: 'requested',
          },
          relationships: {
            from_location: { data: { type: 'locations', id: new_from_location.id } },
            to_location: { data: { type: 'locations', id: new_to_location.id } },
          },
        }
      end

      it 'does not affect both from_location and to_location' do
        expect { do_patch }.not_to change {
          [move.reload.from_location,
           move.reload.to_location]
        }
      end
    end

    context 'when cancelling a move' do
      let(:move_params) do
        {
          type: 'moves',
          attributes: {
            status: 'cancelled',
            cancellation_reason: 'other',
          },
        }
      end

      context 'when an allocation is associated with the move' do
        before { do_patch }

        let!(:allocation) { create :allocation, moves_count: 1 }
        let!(:move) { create :move, :requested, from_location: from_location, allocation: allocation }

        it 'updates the allocation moves_count' do
          expect(allocation.reload.moves_count).to eq(0)
        end

        it 'updates the allocation status to unfilled' do
          expect(move.reload.allocation).to be_unfilled
        end
      end

      context 'when the supplier has a webhook subscription' do
        let!(:subscription) { create(:subscription, :no_email_address, supplier: supplier) }
        let(:notification) { subscription.notifications.last }
        let(:faraday_client) do
          class_double(
            Faraday,
            headers: {},
            post: instance_double(Faraday::Response, success?: true, status: 202),
          )
        end

        let(:expected_notification) do
          {
            'subscription_id' => subscription.id,
            'event_type' => 'update_move_status',
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

        it 'generates the correct notification' do
          create(:notification_type, :webhook)
          allow(Faraday).to receive(:new).and_return(faraday_client)
          perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
            do_patch
          end

          expect(notification.attributes).to include_json(expected_notification)
        end
      end

      context 'when the supplier has an email subscription' do
        let!(:subscription) { create(:subscription, :no_callback_url, supplier: supplier) }
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

        let(:expected_notification) do
          {
            'subscription_id' => subscription.id,
            'event_type' => 'update_move_status',
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

        it 'generates the correct notification' do
          create(:notification_type, :email)
          allow(MoveMailer).to receive(:notify).and_return(notify_response)
          perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
            do_patch
          end

          expect(notification.attributes).to include_json(expected_notification)
        end
      end
    end

    context 'when updating an existing requested move without a change of move_status' do
      let!(:move) { create :move, :requested, move_type: 'prison_recall', from_location: from_location, supplier: supplier }

      context 'when the supplier has a webhook subscription' do
        # NB: updates to existing moves should trigger a webhook notification
        let!(:subscription) { create(:subscription, :no_email_address, supplier: supplier) }
        let!(:notification_type_webhook) { create(:notification_type, :webhook) }
        let(:notification) { subscription.notifications.last }
        let(:faraday_client) do
          class_double(
            Faraday,
            headers: {},
            post: instance_double(Faraday::Response, success?: true, status: 202),
          )
        end
        let(:move_params) do
          {
            type: 'moves',
            attributes: {
              status: move.status,
            },
          }
        end

        before do
          allow(Faraday).to receive(:new).and_return(faraday_client)
          perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
            do_patch
          end
        end

        it 'has correct attributes' do
          expect(notification).to have_attributes(
            delivered_at: a_value,
            topic: move,
            notification_type: notification_type_webhook,
            event_type: 'update_move',
            response_id: nil,
          )
        end
      end

      context 'when the supplier has an email subscription' do
        # NB: updates to existing moves should trigger an email notification
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
        let(:move_params) do
          {
            type: 'moves',
            attributes: {
              status: move.status,
            },
          }
        end

        before do
          allow(MoveMailer).to receive(:notify).and_return(notify_response)
          perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyEmailJob]) do
            do_patch
          end
        end

        it 'creates an email notification' do
          expect(subscription.notifications.count).to be 1
        end
      end
    end

    context 'when updating an existing requested move' do
      before do
        create(
          :move,
          :requested,
          profile: profile,
          from_location: move.from_location,
          to_location: move.to_location,
          date: move.date,
        )
        do_patch
      end

      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => 'Date has already been taken',
            'source' => { 'pointer' => '/data/attributes/date' },
            'code' => 'taken',
          },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422'
    end

    context 'when updating a read-only attribute' do
      let!(:move) { create :move }

      let(:move_params) do
        {
          type: 'moves',
          attributes: {
            status: 'cancelled',
            cancellation_reason: 'supplier_declined_to_move',
            reference: 'new reference',
          },
        }
      end

      it 'updates the status of a move' do
        do_patch
        expect(move.reload.status).to eq 'cancelled'
      end

      it 'does NOT update the reference of a move' do
        expect { do_patch }.not_to change { move.reload.reference }
      end

      it_behaves_like 'an endpoint that responds with success 200' do
        before { do_patch }
      end
    end

    context 'when no request params are provided' do
      let(:move_params) { nil }

      it_behaves_like 'an endpoint that responds with error 400' do
        before { do_patch }
      end
    end

    context 'when the move does not exist' do
      let(:move_id) { 'foo' }
      let(:move_params) { nil }
      let(:detail_404) { "Couldn't find Move with 'id'=foo" }

      it_behaves_like 'an endpoint that responds with error 404' do
        before { do_patch }
      end
    end

    context 'when the specified params are not valid' do
      let(:move_params) do
        {
          type: 'moves',
          attributes: {
            status: 'invalid',
          },
        }
      end

      let(:errors_422) do
        [
          {
            'title' => 'Invalid status',
            'detail' => /Status is not included in the list/,
          },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_patch }
      end
    end

    context 'when the profile is for an unsupported prisoner category' do
      let(:new_profile) { create(:profile, :category_not_supported) }
      let(:category_key) { new_profile.category.key.humanize.downcase }
      let(:move_params) do
        {
          type: 'moves',
          attributes: {
            status: 'requested',
          },
          relationships: { profile: { data: { id: new_profile.id, type: 'profiles' } } },
        }
      end
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
        before { do_patch }
      end
    end

    context 'when the profile is for a supported prisoner category' do
      let(:new_profile) { create(:profile, :category_supported) }
      let(:move_params) do
        {
          type: 'moves',
          attributes: {
            status: 'requested',
          },
          relationships: { profile: { data: { id: new_profile.id, type: 'profiles' } } },
        }
      end

      it_behaves_like 'an endpoint that responds with success 200' do
        before { do_patch }
      end
    end

    context 'when updating the date' do
      let(:move_params) do
        {
          type: 'moves',
          attributes: {
            date: '2019-08-23',
          },
        }
      end

      let(:move_date_changed_event) { move.generic_events.where(type: 'GenericEvent::MoveDateChanged').first }

      it 'changes the move date' do
        expect { do_patch }.to change { move.reload.date }.to(Date.parse('2019-08-23'))
      end

      it 'creates a GenericEvent::MoveDateChanged event' do
        do_patch
        expect(move_date_changed_event).to be_present
        expect(move_date_changed_event.date).to eql '2019-08-23'
      end
    end

    def do_patch
      patch "/api/moves/#{move_id}", params: patch_params, headers: headers, as: :json
    end
  end
end
