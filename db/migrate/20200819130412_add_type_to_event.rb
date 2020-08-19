class AddTypeToEvent < ActiveRecord::Migration[6.0]
  def change
    # This column is going to be null for some events (specifically,
    # those ones that have been created through the legacy api).
    add_column :events, :type, :string
  end
end
