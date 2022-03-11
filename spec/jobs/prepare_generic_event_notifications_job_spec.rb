# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrepareGenericEventNotificationsJob, type: :job do
  subject(:perform) do
    described_class.perform_now(
      topic_id: generic_event.id,
      action_name: 'create_event',
      queue_as: :some_queue_name,
      send_webhooks: true,
      send_emails: false,
      only_supplier_id: nil,
    )
  end

  let(:subscription) { create :subscription }
  let(:supplier) { create :supplier, name: 'test', subscriptions: [subscription] }
  let(:location) { create :location, suppliers: [supplier] }
  let(:move) { create :move, from_location: location, supplier: supplier }
  let(:per) { create :person_escort_record, move: move }
  let(:generic_event) { create :event_per_generic, eventable: per }

  before do
    create(:notification_type, :webhook)

    allow(NotifyWebhookJob).to receive(:perform_later)
    allow(NotifyEmailJob).to receive(:perform_later)
  end

  context 'when notifying about a generic event' do
    it 'creates a webhook notification record' do
      expect { perform }.to change(Notification.webhooks, :count).by(1)
    end

    it 'does not create an email notification record' do
      expect { perform }.not_to change(Notification.emails, :count)
    end

    it 'schedules NotifyWebhookJob' do
      perform

      expect(NotifyWebhookJob).to have_received(:perform_later)
                                    .with(notification_id: Notification.webhooks.last.id, queue_as: :some_queue_name)
    end

    it 'does not schedule a NotifyEmailJob' do
      perform

      expect(NotifyEmailJob).not_to have_received(:perform_later)
    end
  end
end
