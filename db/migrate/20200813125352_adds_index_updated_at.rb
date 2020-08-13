class AddsIndexUpdatedAt < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :people, :updated_at, algorithm: :concurrently
    add_index :profiles, :updated_at, algorithm: :concurrently
    add_index :events, :updated_at, algorithm: :concurrently
    add_index :journeys, :updated_at, algorithm: :concurrently
  end
end
