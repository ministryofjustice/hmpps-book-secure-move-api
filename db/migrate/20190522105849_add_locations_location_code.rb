class AddLocationsLocationCode < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :location_code, :string
    remove_column :locations, :label
    change_column :locations, :description, :string, null: false
  end
end
