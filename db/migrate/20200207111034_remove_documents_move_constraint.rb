class RemoveDocumentsMoveConstraint < ActiveRecord::Migration[5.2]
  def up
    change_column_null :documents, :move_id, :uuid, true
  end
  def down
    change_column_null :documents, :move_id, :uuid, false
  end
end
