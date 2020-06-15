class CreateLocationsSuppliers < ActiveRecord::Migration[5.2]
  def change
    create_join_table :locations, :suppliers, column_options: { type: :uuid, null: false, index: true, foreign_key: true } do |t|
      t.index %i[location_id supplier_id], unique: true
      t.index %i[supplier_id location_id], unique: true
      t.timestamps
    end
  end
end
