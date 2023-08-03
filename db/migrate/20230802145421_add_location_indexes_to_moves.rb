class AddLocationIndexesToMoves < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :moves, :from_location_id, algorithm: :concurrently
    add_index :moves, :to_location_id, algorithm: :concurrently
  end
end
