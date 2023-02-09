require 'rails_helper'

RSpec.describe RequeueUnsentNotificationsWorker, type: :worker do
  subject(:worker) { described_class.new }

  let(:notification_type) { create(:notification_type, :webhook) }
  let(:updated_at) { 4.hours.ago }

  let!(:notification) do
    create(
      :notification,
      notification_type: notification_type,
      updated_at: updated_at,
      delivery_attempts: delivery_attempts,
    )
  end

  let(:notification_job) { NotifyWebhookJob }

  let(:logger) { instance_spy(Logger) }

  before do
    allow(Rails).to receive(:logger).and_return(logger)
    allow(notification_job).to receive(:perform_later)
  end

  shared_examples 'it gets requeued' do
    it 'runs the notify webhook job' do
      worker.perform

      expect(notification_job)
        .to have_received(:perform_later)
        .with(notification_id: notification.id, queue_as: :notifications_high)
    end

    it 'logs that the job was recreated' do
      worker.perform

      expect(logger).to have_received(:info).with(
        "[RequeueUnsentNotificationsWorker] #{notification_job} recreated for " \
        "Notification ID #{notification.id}",
      )
    end
  end

  shared_examples 'it does not get requeued' do
    it 'does not run the notify webhook job' do
      worker.perform

      expect(NotifyWebhookJob).not_to have_received(:perform_later)
    end
  end

  context 'when delivery already attempted' do
    let(:delivery_attempts) { 1 }

    it_behaves_like 'it does not get requeued'
  end

  context 'when delivery not attempted' do
    let(:delivery_attempts) { 0 }

    it_behaves_like 'it gets requeued'

    context 'when created within the last hour' do
      let(:updated_at) { 1.second.ago }

      it_behaves_like 'it does not get requeued'
    end

    context 'when created over one day ago' do
      let(:updated_at) { 2.days.ago }

      it_behaves_like 'it does not get requeued'
    end

    context 'when email notification' do
      let(:notification_type) { create(:notification_type, :email) }
      let(:notification_job) { NotifyEmailJob }

      it_behaves_like 'it gets requeued'
    end
  end
end
