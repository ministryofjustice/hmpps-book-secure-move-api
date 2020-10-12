class CreatePopulations < ActiveRecord::Migration[6.0]
  def change
    create_table :populations, id: :uuid do |t|
      t.references :location, foreign_key: true, null: false, type: :uuid
      t.date :date, null: false, index: true
      t.integer :operational_capacity, null: false
      t.integer :usable_capacity, null: false
      t.integer :unlock, null: false
      t.integer :bedwatch, null: false
      t.integer :overnights_in, null: false
      t.integer :overnights_out, null: false
      t.integer :out_of_area_courts, null: false
      t.integer :discharges, null: false
      t.string :updated_by

      t.timestamps
    end
  end
end
