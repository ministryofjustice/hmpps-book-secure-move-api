class AddMovesReference < ActiveRecord::Migration[5.2]
  def change
    add_column :moves, :reference, :string
    add_index :moves, :reference, unique: true
  end
end
