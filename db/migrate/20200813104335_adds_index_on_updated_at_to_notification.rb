class AddsIndexOnUpdatedAtToNotification < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :notifications, :updated_at, algorithm: :concurrently
  end
end
