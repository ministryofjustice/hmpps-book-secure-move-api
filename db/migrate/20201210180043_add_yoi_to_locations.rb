class AddYoiToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :young_offender_institution, :boolean, default: false
    add_index :locations, :young_offender_institution
  end
end
