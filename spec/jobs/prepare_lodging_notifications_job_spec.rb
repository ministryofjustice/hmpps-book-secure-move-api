# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrepareLodgingNotificationsJob, type: :job do
  subject(:perform) do
    described_class.perform_now(
      topic_id: lodging.id,
      action_name: 'cancel',
      queue_as: :some_queue_name,
      send_webhooks: true,
      send_emails: true,
      only_supplier_id: nil,
    )
  end

  let(:subscription) { create :subscription }
  let(:supplier) { create :supplier, name: 'test', subscriptions: [subscription] }
  let(:location) { create :location, suppliers: [supplier] }
  let(:move) { create :move, from_location: location, supplier: }
  let(:lodging) { create :lodging, move: }

  before do
    create(:notification_type, :webhook)
    create(:notification_type, :email)

    allow(NotifyWebhookJob).to receive(:perform_later)
    allow(NotifyEmailJob).to receive(:perform_later)
  end

  describe 'notifying about a lodging' do
    it 'creates a webhook notification record' do
      perform
      expect(Notification.webhooks.last.event_type).to eq('cancel_lodging')
    end

    it 'creates an email notification record' do
      perform
      expect(Notification.emails.last.event_type).to eq('cancel_lodging')
    end

    it 'schedules NotifyWebhookJob' do
      perform
      expect(NotifyWebhookJob)
        .to have_received(:perform_later)
        .once
        .with(notification_id: Notification.webhooks.last.id, queue_as: :some_queue_name)
    end

    it 'schedules NotifyEmailJob' do
      perform
      expect(NotifyEmailJob)
        .to have_received(:perform_later)
        .once
        .with(notification_id: Notification.emails.last.id, queue_as: :some_queue_name)
    end
  end
end
