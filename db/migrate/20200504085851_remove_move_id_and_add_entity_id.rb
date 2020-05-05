class RemoveMoveIdAndAddEntityId < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :entity_id, :uuid, null: false
    add_column :events, :entity_type, :string, null: false
    add_index :events, [:entity_id, :entity_type]
    add_index :events, [:entity_id, :entity_type, :event_name]

    remove_index :events, [:move_id, :event_name]
    remove_index :events, [:move_id, :client_timestamp]
    remove_foreign_key :events, :moves
    remove_column :events, :move_id, :uuid, null: false, index: true
  end
end
