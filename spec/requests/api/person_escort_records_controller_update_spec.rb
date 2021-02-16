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
    let(:attributes) do
      {
        'status': status,
      }
    end
    let(:person_escort_record_params) do
      {
        data: {
          'type': 'person_escort_records',
          'attributes': attributes,
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
              "handover_details": {},
              "handover_occurred_at": nil,
              "version": person_escort_record.framework.version,
              "confirmed_at": person_escort_record.confirmed_at.iso8601,
            },
          })
        end
      end

      context 'when including handover details' do
        let(:timestamp) { Time.zone.now }
        let(:attributes) do
          {
            'status': status,
            'handover_details': {
              'recipient_name': 'Fulton McKay',
              'recipient_id': '12345',
              'recipient_contact_number': '01-811-8055',
            },
            'handover_occurred_at': timestamp.iso8601,
          }
        end

        it_behaves_like 'an endpoint that responds with success 200'

        it 'returns the correct handover details' do
          expect(response_json).to include_json(data: {
            'attributes': {
              'handover_details': {
                'recipient_name': 'Fulton McKay',
                'recipient_id': '12345',
                'recipient_contact_number': '01-811-8055',
              },
              'handover_occurred_at': timestamp.iso8601,
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
            [
              {
                'title' => 'Unprocessable entity',
                'detail' => "Status can't update to 'confirmed' from 'in progress'",
                'source' => { 'pointer' => '/data/attributes/status' },
                'code' => 'invalid_status',
              },
            ]
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
        perform_enqueued_jobs(only: [PreparePersonEscortRecordNotificationsJob, PrepareAssessmentNotificationsJob, NotifyWebhookJob, NotifyEmailJob]) do
          patch_person_escort_record
        end
      end

      context 'when excluding handover details' do
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
      end

      context 'when including handover details' do
        let(:timestamp) { Time.zone.now }
        let(:attributes) do
          {
            'status': status,
            'handover_details': {
              'recipient_name': 'Fulton McKay',
              'recipient_id': '12345',
              'recipient_contact_number': '01-811-8055',
            },
            'handover_occurred_at': timestamp.iso8601,
          }
        end

        it 'creates a webhook notification' do
          notification = subscription.notifications.find_by(notification_type: notification_type_webhook)

          expect(notification).to have_attributes(
            topic: person_escort_record,
            notification_type: notification_type_webhook,
            event_type: 'handover_person_escort_record',
          )
        end

        it 'does not create an email notification' do
          notification = subscription.notifications.find_by(notification_type: notification_type_email)

          expect(notification).to be_nil
        end
      end

      context 'when request is unsuccessful' do
        let(:status) { 'foo-bar' }

        it 'does not create notifications' do
          expect(subscription.notifications).to be_empty
        end
      end
    end

    context 'with confirmation event' do
      it 'creates a per confirmation event' do
        expect { patch_person_escort_record }.to change(GenericEvent, :count).by(1)
      end

      it 'persists correct attributes to a per confirmation event' do
        recorded_timestamp = Time.zone.parse('2020-10-07 01:02:03')
        Timecop.freeze(recorded_timestamp)
        patch_person_escort_record
        Timecop.return

        event = GenericEvent.find_by(eventable: person_escort_record, type: 'GenericEvent::PerConfirmation')

        expect(event).to have_attributes(
          created_by: 'TEST_USER',
          occurred_at: recorded_timestamp,
          recorded_at: recorded_timestamp,
          details: { 'confirmed_at' => person_escort_record.confirmed_at },
          notes: 'Automatically generated event',
        )
      end

      context 'when request is unsuccessful' do
        let(:status) { 'foo-bar' }

        it 'does not create confirmation event' do
          expect { patch_person_escort_record }.not_to change(GenericEvent, :count)
        end
      end

      context 'when Person Escort Record is already confirmed' do
        it 'does not create confirmation event' do
          patch_person_escort_record

          expect { patch_person_escort_record }.not_to change(GenericEvent, :count)
        end
      end
    end

    context 'with handover event' do
      let(:occurred_timestamp) { Time.zone.now }
      let(:handover_details) do
        {
          'recipient_name': 'Fulton McKay',
          'recipient_id': '12345',
          'recipient_contact_number': '01-811-8055',
        }
      end
      let(:attributes) do
        {
          'status': status,
          'handover_details': handover_details,
          'handover_occurred_at': occurred_timestamp.iso8601,
        }
      end

      it 'creates a per handover event' do
        expect { patch_person_escort_record }.to change(GenericEvent, :count).by(1)
      end

      it 'persists correct attributes to a per handover event' do
        recorded_timestamp = Time.zone.parse('2020-10-07 01:02:03')
        Timecop.freeze(recorded_timestamp) do
          patch_person_escort_record
        end

        event = GenericEvent.find_by(eventable: person_escort_record, type: 'GenericEvent::PerHandover')

        expect(event).to have_attributes(
          created_by: 'TEST_USER',
          occurred_at: occurred_timestamp,
          recorded_at: recorded_timestamp,
          details: handover_details,
          notes: 'Automatically generated event',
        )
      end
    end
  end
end
