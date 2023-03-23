class AddBodyToAccessLogs < ActiveRecord::Migration[6.1]

  def change
    add_column :access_logs, :body, :json
  end
end
