class RemoveUniqueIndexFromLodgings < ActiveRecord::Migration[7.0]
  def change
    remove_index :lodgings, 'start_date_and_move_id'
  end
end
