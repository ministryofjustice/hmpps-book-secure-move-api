class RenameLocationCode < ActiveRecord::Migration[5.2]
  def change
    rename_column :locations, :location_code, :nomis_agency_id
  end
end
