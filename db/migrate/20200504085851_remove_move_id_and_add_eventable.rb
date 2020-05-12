class RemoveMoveIdAndAddEventable < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :eventable_id, :uuid, null: false
    add_column :events, :eventable_type, :string, null: false
    add_index :events, [:eventable_id, :eventable_type]
    add_index :events, [:eventable_id, :eventable_type, :event_name]

    remove_index :events, [:move_id, :event_name]
    remove_index :events, [:move_id, :client_timestamp]
    remove_foreign_key :events, :moves
    remove_column :events, :move_id, :uuid, null: false, index: true
  end
end
