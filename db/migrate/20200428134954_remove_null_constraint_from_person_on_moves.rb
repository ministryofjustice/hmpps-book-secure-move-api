class RemoveNullConstraintFromPersonOnMoves < ActiveRecord::Migration[5.2]
  def change
    change_column :moves, :person_id, :uuid, null: true
  end
end
