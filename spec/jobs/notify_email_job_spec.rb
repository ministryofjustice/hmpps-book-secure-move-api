# frozen_string_literal: true

RSpec.describe NotifyEmailJob, type: :job do
  subject(:perform!) { described_class.new.perform(notification_id: notification.id) }

  let(:perform_ignore_errors!) { perform! rescue nil }
  let(:subscription) { create(:subscription, :no_callback_url) }
  let(:notification) { create(:notification, :email, subscription: subscription, delivered_at: nil, delivery_attempted_at: nil) }
  let(:govuk_notify_api_key) { 'GOVUK_NOTIFY_API_KEY' }
  let(:govuk_notify_template_id) { 'GOVUK_NOTIFY_API_KEY' }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('GOVUK_NOTIFY_API_KEY', nil).and_return(govuk_notify_api_key)
    allow(ENV).to receive(:fetch).with('GOVUK_NOTIFY_TEMPLATE_ID', nil).and_return(govuk_notify_template_id)
  end

  context 'when GOVUK_NOTIFY_API_KEY env var is not set' do
    let(:govuk_notify_api_key) { nil }

    it 'returns nil' do
      expect(perform!).to be_nil
    end
  end

  context 'when GOVUK_NOTIFY_TEMPLATE_ID env var is not set' do
    let(:govuk_notify_template_id) { nil }

    it 'returns nil' do
      expect(perform!).to be_nil
    end
  end

  context 'when notification and subscription are active' do
    context 'when the email is successfully delivered to Gov.uk Notify' do
      let(:notify_response) {
        instance_double(Mail::Message, deliver!:
            instance_double(Mail::Message, govuk_notify_response:
                instance_double(Notifications::Client::ResponseNotification, id: response_id)))
      }
      let(:response_id) { SecureRandom.uuid }

      before { allow(MoveMailer).to receive(:notify).and_return(notify_response) }

      it 'notifies the mailer' do
        perform!
        expect(MoveMailer).to have_received(:notify)
      end

      it 'updates delivered_at' do
        expect { perform! }.to change { notification.reload.delivered_at }.from(nil)
      end

      it 'updates delivery_attempted_at' do
        expect { perform! }.to change { notification.reload.delivery_attempted_at }.from(nil)
      end

      it 'updates delivery_attempts' do
        expect { perform! }.to change { notification.reload.delivery_attempts }.from(0).to(1)
      end

      it 'updates response_id' do
        expect { perform! }.to change { notification.reload.response_id }.from(nil).to(response_id)
      end
    end

    context 'when Gov.uk Notify does not respond' do
      let(:notify_response) {
        instance_double(Mail::Message, deliver!:
            instance_double(Mail::Message, govuk_notify_response: nil))
      }

      before { allow(MoveMailer).to receive(:notify).and_return(notify_response) }

      it 'notifies the mailer' do
        perform_ignore_errors!
        expect(MoveMailer).to have_received(:notify)
      end

      it 'does not set delivered_at' do
        expect { perform_ignore_errors! }.not_to change { notification.reload.delivered_at }.from(nil)
      end

      it 'updates delivery_attempted_at' do
        expect { perform_ignore_errors! }.to change { notification.reload.delivery_attempted_at }.from(nil)
      end

      it 'updates delivery_attempts' do
        expect { perform_ignore_errors! }.to change { notification.reload.delivery_attempts }.from(0).to(1)
      end

      it 'does not set response_id' do
        expect { perform_ignore_errors! }.not_to change { notification.reload.response_id }.from(nil)
      end

      it 'raises Notification failed error' do
        expect { perform! }.to raise_error('Email notification failed')
      end
    end

    context 'when there is an unexpected error' do
      before { allow(MoveMailer).to receive(:notify).and_raise('Some unexpected error') }

      it 'notifies the mailer' do
        perform_ignore_errors!
        expect(MoveMailer).to have_received(:notify)
      end

      it 'does not set delivered_at' do
        expect { perform_ignore_errors! }.not_to change { notification.reload.delivered_at }.from(nil)
      end

      it 'updates delivery_attempted_at' do
        expect { perform_ignore_errors! }.to change { notification.reload.delivery_attempted_at }.from(nil)
      end

      it 'updates delivery_attempts' do
        expect { perform_ignore_errors! }.to change { notification.reload.delivery_attempts }.from(0).to(1)
      end

      it 'does not set response_id' do
        expect { perform_ignore_errors! }.not_to change { notification.reload.response_id }.from(nil)
      end

      it 'raises Notification failed error' do
        expect { perform! }.to raise_error('Email notification failed')
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
