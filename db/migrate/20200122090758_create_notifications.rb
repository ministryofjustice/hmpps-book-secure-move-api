class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :subscription, foreign_key: true, null: false, type: :uuid, index: true
      t.datetime :time_stamp, null: false, index: true
      t.string :event_type, null: false, index: true
      t.uuid :topic_id, null: false, index: true
      t.string :topic_type, null: false, index: true
      t.integer :delivery_attempts, null: false, default: 0
      t.datetime :delivery_attempted_at
      t.datetime :delivered_at, index: true
      # NB: no requirement to store JSON payload for now

      t.timestamps
    end
    add_index :notifications, [:topic_type, :topic_id]
  end
end
