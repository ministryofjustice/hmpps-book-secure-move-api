class AddOriginalMoveIdToMoves < ActiveRecord::Migration[6.0]
  def change
    add_column :moves, :original_move_id, :uuid
    add_foreign_key :moves, :moves, column: :original_move_id
  end
end
