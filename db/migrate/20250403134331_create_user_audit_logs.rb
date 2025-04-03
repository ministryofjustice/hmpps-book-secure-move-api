class CreateUserAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :user_audit_logs, id: :uuid do |t|
      t.string :name, index: true
      t.string :ip_address, index: true
      t.timestamps
    end
  end
end
