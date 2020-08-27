# frozen_string_literal: true

RSpec.describe PreparePersonEscortRecordNotificationsJob, type: :job do
  subject(:perform) { described_class.new.perform(topic_id: person_escort_record.id, action_name: 'update') }

  let(:subscription) { create(:subscription) }
  let(:supplier) { create :supplier, name: 'test', subscriptions: [subscription] }
  let(:location) { create :location, suppliers: [supplier] }
  let(:person_escort_record) { create(:person_escort_record) }
  let!(:move) { create(:move, from_location: location, profile: person_escort_record.profile, date: Time.zone.today) }

  before do
    create(:notification_type, :webhook)
    create(:notification_type, :email)

    allow(NotifyWebhookJob).to receive(:perform_later)
    allow(NotifyEmailJob).to receive(:perform_later)
  end

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

  context 'when a profile does not have a move' do
    let!(:move) { create(:move, from_location: location) }

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
