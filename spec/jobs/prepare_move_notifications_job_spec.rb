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
    allow(NotifyEmailJob).to receive(:perform_later)
  end

  shared_examples_for 'it creates a webhook notification record' do
    it do
      expect { perform }.to change(Notification.webhooks, :count).by(1)
    end
  end

  shared_examples_for 'it does not create a webhook notification record' do
    it do
      expect { perform }.not_to change(Notification.webhooks, :count)
    end
  end

  shared_examples_for 'it creates an email notification record' do
    it do
      expect { perform }.to change(Notification.emails, :count).by(1)
    end
  end

  shared_examples_for 'it does not create an email notification record' do
    it do
      expect { perform }.not_to change(Notification.emails, :count)
    end
  end

  shared_examples_for 'it schedules NotifyWebhookJob' do
    before { perform }

    it { expect(NotifyWebhookJob).to have_received(:perform_later).with(notification_id: Notification.webhooks.last.id) }
  end

  shared_examples_for 'it does not schedule NotifyWebhookJob' do
    before { perform }

    it { expect(NotifyWebhookJob).not_to have_received(:perform_later) }
  end

  shared_examples_for 'it schedules NotifyEmailJob' do
    before { perform }

    it { expect(NotifyEmailJob).to have_received(:perform_later).with(notification_id: Notification.emails.last.id) }
  end

  shared_examples_for 'it does not schedule NotifyEmailJob' do
    before { perform }

    it { expect(NotifyEmailJob).not_to have_received(:perform_later) }
  end

  context 'when creating a move' do
    let(:action_name) { 'create' }

    context 'when a subscription has both a webhook and email addresses' do
      let(:subscription) { create :subscription }

      it_behaves_like 'it creates a webhook notification record'
      it_behaves_like 'it creates an email notification record'
      it_behaves_like 'it schedules NotifyWebhookJob'
      it_behaves_like 'it schedules NotifyEmailJob'
    end

    context 'when a subscription has no email addresses' do
      let(:subscription) { create :subscription, :no_email_address }

      it_behaves_like 'it creates a webhook notification record'
      it_behaves_like 'it does not create an email notification record'
      it_behaves_like 'it schedules NotifyWebhookJob'
      it_behaves_like 'it does not schedule NotifyEmailJob'
    end

    context 'when a subscription has no webhook' do
      let(:subscription) { create :subscription, :no_callback_url }

      it_behaves_like 'it does not create a webhook notification record'
      it_behaves_like 'it creates an email notification record'
      it_behaves_like 'it schedules NotifyEmailJob'
      it_behaves_like 'it does not schedule NotifyWebhookJob'
    end
  end
end
