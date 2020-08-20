class CreateSupplierLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :supplier_locations, id: :uuid do |t|
      t.references :supplier, type: :uuid, null: false, foreign_key: true
      t.references :location, type: :uuid, null: false, foreign_key: true
      t.date :effective_from, index: true
      t.date :effective_to, index: true
      t.timestamps
    end
  end
end
