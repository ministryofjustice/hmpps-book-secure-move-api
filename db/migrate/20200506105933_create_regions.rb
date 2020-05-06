class CreateRegions < ActiveRecord::Migration[5.2]
  def change
    create_table :regions, id: :uuid do |t|
      t.string :name, null: false
      t.string :key, null: false, index: true
      t.timestamps
    end

    create_join_table :locations, :regions do |t|
      t.references :location, type: :uuid, null: false, index: true, foreign_key: true
      t.references :region, type: :uuid, null: false, index: true, foreign_key: true
      t.index %i[location_id region_id], unique: true
      t.index %i[region_id location_id], unique: true
      t.timestamps
    end
  end
end
