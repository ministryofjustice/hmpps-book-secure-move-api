# frozen_string_literal: true

RSpec.describe PrepareMoveNotificationsJob, type: :job do
  subject(:perform) { described_class.new.perform(topic_id: move.id, action_name: action_name) }

  let(:subscription) { create :subscription }
  let(:supplier) { create :supplier, name: 'test', subscriptions: [subscription] }
  let(:location) { create :location, suppliers: [supplier] }
  let(:move) { create :move, from_location: location }

  before do
    create(:notification_type, :webhook)
    create(:notification_type, :email)
    allow(NotifyWebhookJob).to receive(:perform_later)
  end

  shared_examples_for 'it creates a webhook notification record' do
    it do
      expect { perform }.to change(Notification.where(notification_type_id: 'webhook'), :count).by(1)
    end
  end

  shared_examples_for 'it does not create a webhook notification record' do
    it do
      expect { perform }.not_to change(Notification.where(notification_type_id: 'webhook'), :count)
    end
  end

  shared_examples_for 'it creates an email notification record' do
    it do
      expect { perform }.to change(Notification.where(notification_type_id: 'email'), :count).by(1)
    end
  end

  shared_examples_for 'it does not create an email notification record' do
    it do
      expect { perform }.not_to change(Notification.where(notification_type_id: 'email'), :count)
    end
  end

  context 'when creating a move' do
    let(:action_name) { 'create' }

    context 'when a subscription has both a webhook and email addresses' do
      let(:subscription) { create :subscription, :callback_url, :email_addresses }

      it_behaves_like 'it creates a webhook notification record'
      it_behaves_like 'it creates an email notification record'
    end

    context 'when a subscription has a webhook but no email addresses' do
      let(:subscription) { create :subscription, :callback_url }

      it_behaves_like 'it creates a webhook notification record'
      it_behaves_like 'it does not create an email notification record'
    end

    context 'when a subscription has email addresses but no webhook' do
      let(:subscription) { create :subscription, :email_addresses }

      it_behaves_like 'it does not create a webhook notification record'
      it_behaves_like 'it creates an email notification record'
    end
  end


  # it 'queues a NotifyWebhookJob' do
      #   described_class.new.perform(topic_id: move.id, action_name: 'create')
      #   expect(NotifyWebhookJob).to have_received(:perform_later).with(notification_id: Notification.last.id)
      # end
end
