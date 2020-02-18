# frozen_string_literal: true

RSpec.describe PrepareMoveNotificationsJob, type: :job do
  let(:subscription) { create :subscription }
  let(:supplier) { create :supplier, name: 'test', subscriptions: [subscription] }
  let(:location) { create :location, suppliers: [supplier] }
  let(:move) { create :move, from_location: location }

  before do
    allow(NotifyJob).to receive(:perform_later)
  end

  context 'when called with a move' do
    it 'creates notifications' do
      expect { described_class.new.perform(topic_id: move.id, action_name: 'move_create') }.to change(Notification, :count).by(1)
    end

    it 'queues a Notifyjob' do
      described_class.new.perform(topic_id: move.id, action_name: 'move_create')
      expect(NotifyJob).to have_received(:perform_later).with(notification_id: Notification.last.id)
    end
  end
end
