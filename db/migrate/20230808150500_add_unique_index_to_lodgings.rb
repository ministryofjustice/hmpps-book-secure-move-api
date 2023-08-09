class AddUniqueIndexToLodgings < ActiveRecord::Migration[6.1]
  def change
    add_index :lodgings, [:start_date, :move_id], unique: true
  end
end
