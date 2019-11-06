class UniqueIndexOnMoves < ActiveRecord::Migration[5.2]
  def change
    add_index :moves, [:from_location_id, :to_location_id, :person_id, :date, :time_due], name: 'index_on_move_uniqueness', unique: true
  end
end
