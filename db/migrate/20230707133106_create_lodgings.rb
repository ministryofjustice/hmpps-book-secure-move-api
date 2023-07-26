class CreateLodgings < ActiveRecord::Migration[6.1]
  def change
    create_table :lodgings, id: :uuid do |t|
      t.references :move, type: :uuid, null: false, index: true, foreign_key: true
      t.references :location, type: :uuid, null: false, index: true, foreign_key: true
      t.string :start_date
      t.string :end_date

      t.timestamps
    end
  end
end
