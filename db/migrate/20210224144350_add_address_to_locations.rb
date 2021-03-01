class AddAddressToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :premise, :string
    add_column :locations, :locality, :string
    add_column :locations, :city, :string
    add_column :locations, :country, :string
    add_column :locations, :postcode, :string
  end
end
