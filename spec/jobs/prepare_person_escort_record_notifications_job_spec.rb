# frozen_string_literal: true

RSpec.describe PreparePersonEscortRecordNotificationsJob, type: :job do
  subject(:perform) do
    described_class.perform_now(topic_id: per.id, action_name: action_name, queue_as: :some_queue_name, send_webhooks: send_webhooks, send_emails: send_emails, only_supplier_id: only_supplier_id)
  end

  let(:subscription) { create :subscription }
  let(:supplier) { create :supplier, name: 'test', subscriptions: [subscription] }
  let(:location) { create :location, suppliers: [supplier] }
  let(:move) { create :move, from_location: location, supplier: supplier }
  let(:per) { create :person_escort_record, :amended, move: move }
  let(:action_name) { 'amended' }
  let(:send_webhooks) { true }
  let(:send_emails) { true }
  let(:only_supplier_id) { nil }

  before do
    create(:notification_type, :webhook)
    create(:notification_type, :email)

    allow(NotifyWebhookJob).to receive(:perform_later)
    allow(NotifyEmailJob).to receive(:perform_later)
  end

  context 'when amending a person escort record' do
    let(:action_name) { 'confirm_person_escort_record' }

    it 'creates a webhook notification record' do
      expect { perform }.to change(Notification.webhooks, :count).by(1)
    end

    it 'creates an email notification record' do
      expect { perform }.to change(Notification.emails, :count).by(1)
    end

    it 'schedules NotifyWebhookJob' do
      perform
      expect(NotifyWebhookJob).to have_received(:perform_later).with(notification_id: Notification.webhooks.last.id, queue_as: :some_queue_name)
    end

    it 'schedules NotifyEmailJob' do
      perform
      expect(NotifyEmailJob).to have_received(:perform_later).with(notification_id: Notification.emails.last.id, queue_as: :some_queue_name)
    end
  end
end
