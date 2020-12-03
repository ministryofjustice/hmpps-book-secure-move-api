# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PersonEscortRecordsController do
  describe 'PATCH /person_escort_records/:person_escort_record_id' do
    include_context 'with supplier with spoofed access token'

    subject(:patch_person_escort_record) do
      patch "/api/person_escort_records/#{person_escort_record_id}", params: person_escort_record_params, headers: headers, as: :json

      person_escort_record.reload
    end

    let(:schema) { load_yaml_schema('patch_person_escort_record_responses.yaml') }
    let(:response_json) { JSON.parse(response.body) }
    let(:person_escort_record) { create(:person_escort_record, :with_responses, :completed) }
    let(:person_escort_record_id) { person_escort_record.id }
    let(:status) { 'confirmed' }
    let(:person_escort_record_params) do
      {
        data: {
          "type": 'person_escort_records',
          "attributes": {
            "status": status,
          },
        },
      }
    end

    context 'when successful' do
      before { patch_person_escort_record }

      context 'when status is confirmed' do
        it_behaves_like 'an endpoint that responds with success 200'

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": person_escort_record_id,
            "type": 'person_escort_records',
            "attributes": {
              "status": 'confirmed',
              "version": person_escort_record.framework.version,
              "confirmed_at": person_escort_record.confirmed_at.iso8601,
            },
          })
        end
      end
    end

    context 'when unsuccessful' do
      before { patch_person_escort_record }

      context 'with a bad request' do
        let(:person_escort_record_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'with an invalid status' do
        let(:status) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{ 'title' => 'Invalid status',
               'detail' => 'Validation failed: Status is not included in the list' }]
          end
        end
      end

      context 'when person_escort_record is wrong starting status' do
        let(:person_escort_record) { create(:person_escort_record, :with_responses, :in_progress) }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{ 'title' => 'Invalid status',
               'detail' => "Validation failed: Status can't update to 'confirmed' from 'in_progress'" }]
          end
        end
      end

      context 'when the person_escort_record_id is not found' do
        let(:person_escort_record_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find PersonEscortRecord with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end

    context 'with subscriptions' do
      let!(:subscription) { create(:subscription, supplier: supplier) }
      let!(:notification_type_email) { create(:notification_type, :email) }
      let!(:notification_type_webhook) { create(:notification_type, :webhook) }
      let(:from_location) { create(:location, suppliers: [supplier]) }
      let(:move) { create(:move, from_location: from_location, supplier: supplier) }
      let(:person_escort_record) { create(:person_escort_record, :with_responses, :completed, move: move) }

      let(:faraday_client) do
        class_double(
          Faraday,
          headers: {},
          post: instance_double(Faraday::Response, success?: true, status: 202),
        )
      end
      let(:notify_response) do
        instance_double(
          ActionMailer::MessageDelivery,
          deliver_now!:
          instance_double(
            Mail::Message,
            govuk_notify_response:
            instance_double(Notifications::Client::ResponseNotification, id: SecureRandom.uuid),
          ),
        )
      end

      before do
        allow(Faraday).to receive(:new).and_return(faraday_client)
        allow(MoveMailer).to receive(:notify).and_return(notify_response)
        perform_enqueued_jobs(only: [PrepareAssessmentNotificationsJob, NotifyWebhookJob, NotifyEmailJob]) do
          patch_person_escort_record
        end
      end

      it 'creates a webhook notification' do
        notification = subscription.notifications.find_by(notification_type: notification_type_webhook)

        expect(notification).to have_attributes(
          topic: person_escort_record.move,
          notification_type: notification_type_webhook,
          event_type: 'confirm_person_escort_record',
        )
      end

      it 'creates an email notification' do
        notification = subscription.notifications.find_by(notification_type: notification_type_email)

        expect(notification).to have_attributes(
          topic: person_escort_record.move,
          notification_type: notification_type_email,
          event_type: 'confirm_person_escort_record',
        )
      end

      context 'when request is unsuccessful' do
        let(:status) { 'foo-bar' }

        it 'does not create notifications' do
          expect(subscription.notifications).to be_empty
        end
      end
    end
  end
end
