class AddOriginalMoveIdToMoves < ActiveRecord::Migration[6.0]
  def change
    add_column :moves, :original_move_id, :uuid
  end
end
