class CreateAccessLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :access_logs, id: :uuid do |t|
      t.uuid :request_id
      t.datetime :timestamp
      t.string :whodunnit
      t.string :client
      t.string :verb, null: false
      t.string :controller_name
      t.string :path
      t.string :params
    end
  end
end
