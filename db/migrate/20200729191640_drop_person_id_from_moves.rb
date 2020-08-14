class DropPersonIdFromMoves < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :moves, column: :person_id, to_table: :people
    remove_column :moves, :person_id, :uuid
  end
end
