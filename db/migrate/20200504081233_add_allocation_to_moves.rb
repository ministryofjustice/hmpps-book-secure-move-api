class AddAllocationToMoves < ActiveRecord::Migration[5.2]
  def change
    add_reference :moves, :allocation, type: :uuid, index: true, foreign_key: true
  end
end
