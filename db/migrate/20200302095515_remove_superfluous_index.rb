class RemoveSuperfluousIndex < ActiveRecord::Migration[5.2]
  def up
    remove_index :moves, name: 'index_on_move_uniqueness'
  end
  def down
    add_index :moves, [:from_location_id, :to_location_id, :person_id, :date], name: 'index_on_move_uniqueness', unique: true
  end
end
