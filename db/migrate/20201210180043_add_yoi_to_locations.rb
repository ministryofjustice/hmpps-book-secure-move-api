class AddYoiToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :yoi, :boolean, default: false
    add_index :locations, :yoi
  end
end
