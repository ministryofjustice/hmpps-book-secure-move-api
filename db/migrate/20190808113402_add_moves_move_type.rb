class AddMovesMoveType < ActiveRecord::Migration[5.2]
  def change
    add_column :moves, :move_type, :string, null: true
  end
end
