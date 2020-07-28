# frozen_string_literal: true

RSpec.describe PreparePersonEscortRecordNotificationsJob, type: :job do
  subject(:perform) { described_class.new.perform(topic_id: person_escort_record.id, action_name: 'update') }

  let(:subscription) { create(:subscription) }
  let(:supplier) { create :supplier, name: 'test', subscriptions: [subscription] }
  let(:location) { create :location, suppliers: [supplier] }
  let(:person_escort_record) { create(:person_escort_record) }

  before do
    create(:notification_type, :webhook)
    create(:notification_type, :email)
    create(:move, from_location: location, profile: person_escort_record.profile)

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
    expect(NotifyWebhookJob).to have_received(:perform_later).with(Notification.webhooks.last.id)
  end

  it 'schedules a NotifyEmailJob' do
    perform
    expect(NotifyEmailJob).to have_received(:perform_later).with(Notification.emails.last.id)
  end
end
