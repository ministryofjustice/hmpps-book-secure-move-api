# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['user_audit_logs:cleanup'] do
  before do
    # 2 user_audit_logs to retain (less than 3 months old)
    create(:user_audit_log, created_at: 1.month.ago)
    create(:user_audit_log, created_at: 2.months.ago)

    # 3 user_audit_logs to delete (older than 3 months)
    create(:user_audit_log, created_at: 4.months.ago)
    create(:user_audit_log, created_at: 6.months.ago)
    create(:user_audit_log, created_at: 1.year.ago)

    allow($stdout).to receive(:puts)
    described_class.reenable
    described_class.invoke
  end

  it 'cleans up the user_audit_logs older than 3 months' do
    expect(UserAuditLog.count).to eq(2)
  end

  it 'retains user_audit_logs newer than 3 months' do
    expect(UserAuditLog.where('created_at > ?', 3.months.ago).count).to eq(2)
  end

  it 'deletes user_audit_logs older than 3 months' do
    expect(UserAuditLog.where('created_at < ?', 3.months.ago).count).to eq(0)
  end

  it 'writes to stdout' do
    expect($stdout)
      .to have_received(:puts)
      .with('Cleaning up 3 user audit logs more than 3 months old')
  end
end
