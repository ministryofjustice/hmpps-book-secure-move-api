class CreateMoves < ActiveRecord::Migration[5.2]
  def change
    create_table :moves, id: :uuid do |t|
      t.date :date, null: false
      t.uuid :from_location_id, null: false
      t.uuid :to_location_id, null: false
      t.uuid :person_id, null: false
      t.string :move_type, null: false
      t.string :status, null: false
      t.time :time_due, null: false
      t.timestamps
    end
  end
end
