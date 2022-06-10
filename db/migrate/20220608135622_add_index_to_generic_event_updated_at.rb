class AddIndexToGenericEventUpdatedAt < ActiveRecord::Migration[6.1]
  def change
    add_index :generic_events, :updated_at, if_not_exists: true
  end
end
