class RemoveNomisEventIdsFromMoves < ActiveRecord::Migration[6.0]
  def up
    remove_column :moves, :nomis_event_ids
  end

  def down
    add_column :moves, :nomis_event_ids, :integer, array: true, null: false, default: []
  end
end
