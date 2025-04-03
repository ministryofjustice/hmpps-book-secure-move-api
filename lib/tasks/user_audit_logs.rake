namespace :user_audit_logs do
  desc 'Cleanup user audit logs more than 3 months old'
  task cleanup: [:environment] do
    cutoff_date = 3.months.ago
    count = UserAuditLog.where('created_at < ?', cutoff_date).count

    puts "Cleaning up #{count} user audit logs more than 3 months old"
    UserAuditLog.where('created_at < ?', cutoff_date).delete_all
  end
end
