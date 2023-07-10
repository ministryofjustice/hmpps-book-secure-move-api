class AddIndexToAccessLogsTimestamp < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :access_logs, :timestamp, algorithm: :concurrently
  end
end
