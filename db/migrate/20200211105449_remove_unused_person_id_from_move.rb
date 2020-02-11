class RemoveUnusedPersonIdFromMove < ActiveRecord::Migration[5.2]
  def up
    remove_column :moves, :person_id
  end
  def down
    change_table :moves do |t|
      t.uuid :person_id
      t.index ["from_location_id", "to_location_id", "person_id", "date"], name: "index_on_move_uniqueness", unique: true
    end
  end
end
