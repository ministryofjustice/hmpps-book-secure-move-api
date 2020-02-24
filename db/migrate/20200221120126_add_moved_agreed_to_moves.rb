class AddMovedAgreedToMoves < ActiveRecord::Migration[5.2]
  def change
    add_column :moves, :move_agreed, :boolean
    add_column :moves, :move_agreed_by, :string
  end
end
