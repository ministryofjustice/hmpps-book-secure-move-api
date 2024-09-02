# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotifyEmailJob, type: :job do
  subject(:perform!) { described_class.perform_now(notification_id: notification.id) }

  let(:perform_and_ignore_errors!) do
    perform!
  rescue StandardError
    nil
  end
  let(:subscription) { create(:subscription, :no_callback_url) }
  let(:notification) { create(:notification, :email, subscription:, delivered_at:, delivery_attempted_at: nil) }
  let(:delivered_at) { nil }
  let(:govuk_notify_api_key) { 'GOVUK_NOTIFY_API_KEY' }
  let(:govuk_notify_move_template_id) { 'GOVUK_NOTIFY_MOVE_TEMPLATE_ID' }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('GOVUK_NOTIFY_API_KEY', nil).and_return(govuk_notify_api_key)
    allow(ENV).to receive(:fetch).with('GOVUK_NOTIFY_MOVE_TEMPLATE_ID', nil).and_return(govuk_notify_move_template_id)
    ActionMailer::Base.add_delivery_method :govuk_notify, GovukNotifyRails::Delivery, api_key: govuk_notify_api_key
  end

  context 'when GOVUK_NOTIFY_API_KEY env var is not set' do
    let(:govuk_notify_api_key) { nil }

    it 'raises an NoMethodError' do
      expect { perform! }.to raise_error(RetryJobError, /undefined method `length' for nil/)
    end
  end

  context 'when GOVUK_NOTIFY_MOVE_TEMPLATE_ID env var is not set' do
    let(:govuk_notify_move_template_id) { nil }

    it 'raises an ArgumentError' do
      expect { perform! }.to raise_error(RetryJobError, /Missing template ID/)
    end
  end

  context 'when notification and subscription are active' do
    context 'when the notification has already been delivered' do
      # NB: need to be explicit about the time in the test otherwise there can be a few nanoseconds difference in CircleCI tests
      let(:delivered_at) { Time.zone.parse('2020-02-02 02:02:02.00') }

      before { allow(MoveMailer).to receive(:notify) }

      it 'does not notify the mailer' do
        perform!
        expect(MoveMailer).not_to have_received(:notify)
      end

      it 'returns nil' do
        expect(perform!).to be_nil
      end

      it 'does not set delivered_at' do
        expect { perform_and_ignore_errors! }.not_to change { notification.reload.delivered_at }.from(delivered_at)
      end

      it 'does not update delivery_attempted_at' do
        expect { perform_and_ignore_errors! }.not_to change { notification.reload.delivery_attempted_at }.from(nil)
      end

      it 'does not update delivery_attempts' do
        expect { perform_and_ignore_errors! }.not_to change { notification.reload.delivery_attempts }.from(0)
      end

      it 'does not update response_id' do
        expect { perform_and_ignore_errors! }.not_to change { notification.reload.response_id }.from(nil)
      end
    end

    context 'when the email is successfully delivered to Gov.uk Notify' do
      let(:notify_response) do
        instance_double(
          ActionMailer::MessageDelivery,
          deliver_now!:
                      instance_double(
                        Mail::Message,
                        govuk_notify_response:
                                        instance_double(Notifications::Client::ResponseNotification, id: response_id),
                      ),
        )
      end
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

    context 'when Gov.uk Notify does not respond with a govuk_notify_response object' do
      let(:notify_response) do
        instance_double(
          ActionMailer::MessageDelivery,
          deliver_now!:
                      instance_double(Mail::Message, govuk_notify_response: nil),
        )
      end

      before { allow(MoveMailer).to receive(:notify).and_return(notify_response) }

      it 'notifies the mailer' do
        perform_and_ignore_errors!
        expect(MoveMailer).to have_received(:notify)
      end

      it 'does not set delivered_at' do
        expect { perform_and_ignore_errors! }.not_to change { notification.reload.delivered_at }.from(nil)
      end

      it 'updates delivery_attempted_at' do
        expect { perform_and_ignore_errors! }.to change { notification.reload.delivery_attempted_at }.from(nil)
      end

      it 'updates delivery_attempts' do
        expect { perform_and_ignore_errors! }.to change { notification.reload.delivery_attempts }.from(0).to(1)
      end

      it 'does not set response_id' do
        expect { perform_and_ignore_errors! }.not_to change { notification.reload.response_id }.from(nil)
      end

      it 'raises an error' do
        expect { perform! }.to raise_error(RetryJobError, 'GOV.UK Notify Response is missing')
      end
    end

    context 'when there is an unexpected error' do
      before { allow(MoveMailer).to receive(:notify).and_raise(RuntimeError, 'Some unexpected error') }

      it 'notifies the mailer' do
        perform_and_ignore_errors!
        expect(MoveMailer).to have_received(:notify)
      end

      it 'does not set delivered_at' do
        expect { perform_and_ignore_errors! }.not_to change { notification.reload.delivered_at }.from(nil)
      end

      it 'updates delivery_attempted_at' do
        expect { perform_and_ignore_errors! }.to change { notification.reload.delivery_attempted_at }.from(nil)
      end

      it 'updates delivery_attempts' do
        expect { perform_and_ignore_errors! }.to change { notification.reload.delivery_attempts }.from(0).to(1)
      end

      it 'does not set response_id' do
        expect { perform_and_ignore_errors! }.not_to change { notification.reload.response_id }.from(nil)
      end

      it 'raises an error' do
        expect { perform! }.to raise_error('Some unexpected error')
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
