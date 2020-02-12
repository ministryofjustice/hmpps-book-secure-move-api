# frozen_string_literal: true

RSpec.describe NotifyJob, type: :job do
  subject(:perform!) { described_class.new.perform(notification_id: notification.id) }

  let(:subscription) { create(:subscription) }
  let(:notification) { create(:notification, subscription: subscription, delivered_at: nil, delivery_attempted_at: nil) }
  let(:client) { class_double(Faraday, post: nil) }
  let(:data) { ActiveModelSerializers::Adapter.create(NotificationSerializer.new(notification)).to_json }
  let(:hmac) { Encryptor.hmac(notification.subscription.secret, data) }
  let(:headers) { { 'PECS-SIGNATURE': hmac, 'PECS-NOTIFICATION-ID': notification.id } }

  context 'when notification and subscription are active' do
    before do
      allow(Faraday).to receive(:new).and_return(client)
      allow(client).to receive(:post).and_return(response)
      perform!
    end

    context 'when notification is a success' do
      let(:response) { instance_double(Faraday::Response, success?: true) }

      it 'posts JSON to the callback_url' do
        expect(client).to have_received(:post).with(notification.subscription.callback_url, data, headers)
      end

      it 'updates delivered_at' do
        expect(notification.reload.delivered_at).not_to be_nil
      end
    end

    context 'when notification is not a success' do
      let(:response) { instance_double(Faraday::Response, success?: false) }

      it 'updates delivery_attempts' do
        expect(notification.reload.delivery_attempts).to eq(1)
      end

      it 'updates delivery_attempted_at' do
        expect(notification.reload.delivery_attempted_at).not_to be_nil
      end
    end
  end

  context 'when notification is discarded' do
    before { notification.discard! }

    it 'raises a Record Not Found error' do
      expect { perform! }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
