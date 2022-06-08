class AddIndexToGenericEventUpdatedAt < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :generic_events, :updated_at, algorithm: :concurrently
  end
end
