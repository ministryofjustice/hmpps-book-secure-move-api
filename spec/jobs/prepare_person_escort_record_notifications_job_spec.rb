# frozen_string_literal: true

RSpec.describe PreparePersonEscortRecordNotificationsJob, type: :job do
  subject(:perform) { described_class.new.perform(topic_id: person_escort_record.id, action_name: 'update') }

  let(:subscription) { create(:subscription) }
  let(:supplier) { create :supplier, name: 'test', subscriptions: [subscription] }
  let(:location) { create :location, suppliers: [supplier] }

  before do
    create(:notification_type, :webhook)
    create(:notification_type, :email)

    allow(NotifyWebhookJob).to receive(:perform_later).and_call_original
    allow(NotifyEmailJob).to receive(:perform_later).and_call_original
  end

  context 'with an associated move' do
    let(:move) { create(:move, from_location: location, supplier: supplier, date: Time.zone.today) }
    let(:person_escort_record) { create(:person_escort_record, move: move) }

    it 'creates a webhook notification' do
      expect { perform }.to change(Notification.webhooks, :count).by(1)
    end

    it 'creates an email notification' do
      expect { perform }.to change(Notification.emails, :count).by(1)
    end

    it 'schedules a NotifyWebhookJob' do
      perform
      expect(NotifyWebhookJob).to have_received(:perform_later).with(notification_id: Notification.webhooks.last.id, queue_as: :notifications_high)
    end

    it 'schedules a NotifyEmailJob' do
      perform
      expect(NotifyEmailJob).to have_received(:perform_later).with(notification_id: Notification.emails.last.id, queue_as: :notifications_high)
    end
  end

  context 'without an associated move' do
    let(:person_escort_record) { create(:person_escort_record) }

    it 'does not create notifications' do
      expect { perform }.not_to change(Notification, :count)
    end

    it 'does not schedule a NotifyWebhookJob' do
      perform
      expect(NotifyWebhookJob).not_to have_received(:perform_later)
    end

    it 'does not schedule a NotifyEmailJob' do
      perform
      expect(NotifyEmailJob).not_to have_received(:perform_later)
    end
  end
end
