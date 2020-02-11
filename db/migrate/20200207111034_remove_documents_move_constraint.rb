class RemoveDocumentsMoveConstraint < ActiveRecord::Migration[5.2]
  def change
    change_column :documents, :move_id, :uuid, null: true
  end
end
