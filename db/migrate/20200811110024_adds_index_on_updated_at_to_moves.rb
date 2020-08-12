class AddsIndexOnUpdatedAtToMoves < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :moves, :updated_at, algorithm: :concurrently
  end
end
