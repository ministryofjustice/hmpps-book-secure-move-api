class AddEventIdToMoves < ActiveRecord::Migration[5.2]
  def change
    add_column :moves, :nomis_event_id, :integer
  end
end
