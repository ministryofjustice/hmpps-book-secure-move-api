class AddExtraditionCapableToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :extradition_capable, :boolean
  end
end
