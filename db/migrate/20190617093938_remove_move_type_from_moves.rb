class RemoveMoveTypeFromMoves < ActiveRecord::Migration[5.2]
  def change
    remove_column :moves, :move_type
  end
end
