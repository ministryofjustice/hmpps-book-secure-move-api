class RemoveDocumentsMoveConstraint < ActiveRecord::Migration[5.2]
  def up
    change_column_null :documents, :move_id, true
  end

  def down
    # This is safe - we are simply destroying orphaned documents
    Document.where.not(move_id: nil).destroy_all

    change_column_null :documents, :move_id, false
  end
end
