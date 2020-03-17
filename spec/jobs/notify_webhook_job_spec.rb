# frozen_string_literal: true

RSpec.describe NotifyWebhookJob, type: :job do
  subject(:perform!) { described_class.new.perform(notification_id: notification.id) }

  let(:perform_ignore_errors!) { perform! rescue nil }
  let(:subscription) { create(:subscription, :no_email_address) }
  let(:notification) { create(:notification, :webhook, subscription: subscription, delivered_at: delivered_at, delivery_attempted_at: nil) }
  let(:delivered_at) { nil }
  let(:client) { class_double(Faraday, post: nil) }
  let(:data) { ActiveModelSerializers::Adapter.create(NotificationSerializer.new(notification)).to_json }
  let(:hmac) { Encryptor.hmac(notification.subscription.secret, data) }
  let(:headers) { { 'PECS-SIGNATURE': hmac, 'PECS-NOTIFICATION-ID': notification.id } }

  context 'when notification and subscription are active' do
    before { allow(Faraday).to receive(:new).and_return(client) }

    context 'when the notification has already been delivered' do
      # NB: need to be explicit about the time in the test otherwise there can be a few nanoseconds difference in CircleCI tests
      let(:delivered_at) { DateTime.parse('2020-02-02 02:02:02.00') }

      before { allow(client).to receive(:post) }

      it 'does not notify the webhook' do
        perform!
        expect(client).not_to have_received(:post)
      end

      it 'returns nil' do
        expect(perform!).to be nil
      end

      it 'does not set delivered_at' do
        expect { perform_ignore_errors! }.not_to change { notification.reload.delivered_at }.from(delivered_at)
      end

      it 'does not update delivery_attempted_at' do
        expect { perform_ignore_errors! }.not_to change { notification.reload.delivery_attempted_at }.from(nil)
      end

      it 'does not update delivery_attempts' do
        expect { perform_ignore_errors! }.not_to change { notification.reload.delivery_attempts }.from(0)
      end

      it 'does not update response_id' do
        expect { perform_ignore_errors! }.not_to change { notification.reload.response_id }.from(nil)
      end
    end

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
          expect { perform! }.to raise_error(RuntimeError, /non-success status received/)
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
        expect { perform! }.to raise_error(Faraday::ClientError, 'Internet is unplugged')
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
