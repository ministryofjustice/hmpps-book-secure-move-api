class AddAllocationToMoves < ActiveRecord::Migration[5.2]
  def change
    add_column :moves, :allocation_id, :uuid, null: true
  end
end
