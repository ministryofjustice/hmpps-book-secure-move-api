class AddMovesNomisEventIds < ActiveRecord::Migration[5.2]
  def change
    add_column :moves, :nomis_event_ids, :integer, array: true, null: false, default: [], index: true
  end
end
