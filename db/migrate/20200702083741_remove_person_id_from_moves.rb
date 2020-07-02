class RemovePersonIdFromMoves < ActiveRecord::Migration[6.0]
  def up
    remove_column :moves, :person_id
  end

  def down
    add_reference :moves, :person, type: :uuid, index: true, foreign_key: true
  end
end
