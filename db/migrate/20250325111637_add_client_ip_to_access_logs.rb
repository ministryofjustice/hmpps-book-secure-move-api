class AddClientIpToAccessLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :access_logs, :client_ip, :string
    add_index :access_logs, :client_ip
  end
end
