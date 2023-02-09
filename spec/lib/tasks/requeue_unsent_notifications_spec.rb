# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['requeue_unsent_notifications'] do
  before do
    allow(RequeueUnsentNotificationsWorker).to receive(:perform_async)
    allow($stdout).to receive(:puts)

    described_class.reenable
    described_class.invoke
  end

  it 'queues the RequeueUnsentNotificationsWorker worker' do
    expect(RequeueUnsentNotificationsWorker).to have_received(:perform_async)
  end

  it 'logs that it queued the worker' do
    expect($stdout)
      .to have_received(:puts)
      .with('The RequeueUnsentNotificationsWorker has been queued.')
  end
end
