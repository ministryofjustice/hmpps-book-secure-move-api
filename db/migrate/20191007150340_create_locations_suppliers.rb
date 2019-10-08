class CreateLocationsSuppliers < ActiveRecord::Migration[5.2]
  def change
    create_table :locations_suppliers, id: false do |t|
      t.references :location, type: :uuid, null: false, foreign_key: true, index: true
      t.references :supplier, type: :uuid, null: false, foreign_key: true, index: true
      t.timestamps
    end
  end
end
