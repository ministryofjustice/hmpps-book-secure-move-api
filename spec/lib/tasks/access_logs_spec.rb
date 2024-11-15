# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['access_logs:cleanup'] do
  before do
    # 2 access_logs to retain
    create(:access_log, timestamp: 1.month.ago)
    create(:access_log, timestamp: 2.months.ago)

    # 3 access_logs to delete
    create(:access_log, timestamp: 7.months.ago)
    create(:access_log, timestamp: 8.months.ago)
    create(:access_log, timestamp: 9.months.ago)

    allow($stdout).to receive(:puts)

    described_class.invoke
  end

  it 'cleans up the access_logs and writes to stdout' do
    expect(AccessLog.count).to eq(2)

    expect($stdout)
      .to have_received(:puts)
      .with('Cleaning up 3 access_logs in 1 iterations')
  end
end
