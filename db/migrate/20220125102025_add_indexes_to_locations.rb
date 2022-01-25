class AddIndexesToLocations < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :locations, :location_type, algorithm: :concurrently
    add_index :locations, :nomis_agency_id, algorithm: :concurrently
  end
end
