# frozen_string_literal: true

RSpec.describe NotifyWebhookJob, type: :job do
  subject(:perform!) { described_class.new.perform(notification_id: notification.id) }

  let(:perform_ignore_errors!) { perform! rescue nil }
  let(:subscription) { create(:subscription, :no_email_address) }
  let(:notification) { create(:notification, :webhook, subscription: subscription, delivered_at: nil, delivery_attempted_at: nil) }
  let(:client) { class_double(Faraday, post: nil) }
  let(:data) { ActiveModelSerializers::Adapter.create(NotificationSerializer.new(notification)).to_json }
  let(:hmac) { Encryptor.hmac(notification.subscription.secret, data) }
  let(:headers) { { 'PECS-SIGNATURE': hmac, 'PECS-NOTIFICATION-ID': notification.id } }

  context 'when notification and subscription are active' do
    before { allow(Faraday).to receive(:new).and_return(client) }

    context 'when a response is received from the callback_url' do
      before { allow(client).to receive(:post).and_return(response) }

      context 'when the callback response is a success' do
        let(:response) { instance_double(Faraday::Response, success?: true, status: 202) }

        before { perform! }

        it 'posts JSON to the callback_url' do
          expect(client).to have_received(:post).with(notification.subscription.callback_url, data, headers)
        end

        it 'updates delivered_at' do
          expect(notification.reload.delivered_at).not_to be_nil
        end
      end

      context 'when the callback response is a failure' do
        let(:response) { instance_double(Faraday::Response, success?: false, status: 503) }

        it 'raises Notification failed error' do
          expect { perform! }.to raise_error('Webhook notification failed')
        end

        it 'updates delivery_attempts' do
          expect { perform_ignore_errors! }.to change { notification.reload.delivery_attempts }.from(0).to(1)
        end

        it 'updates delivery_attempted_at' do
          expect { perform_ignore_errors! }.to change { notification.reload.delivery_attempted_at }.from(nil)
        end
      end
    end

    context 'when an error is raised by Faraday' do
      before do
        allow(client).to receive(:post).and_raise(Faraday::ClientError.new('Internet is unplugged'))
      end

      it 'raises Notification failed error' do
        expect { perform! }.to raise_error('Webhook notification failed')
      end

      it 'updates delivery_attempts' do
        expect { perform_ignore_errors! }.to change { notification.reload.delivery_attempts }.from(0).to(1)
      end

      it 'updates delivery_attempted_at' do
        expect { perform_ignore_errors! }.to change { notification.reload.delivery_attempted_at }.from(nil)
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
