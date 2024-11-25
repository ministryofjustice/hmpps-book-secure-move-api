class AddIndexToGenericEventsType < ActiveRecord::Migration[8.0]
  def change
    add_index :generic_events, :type
  end
end
