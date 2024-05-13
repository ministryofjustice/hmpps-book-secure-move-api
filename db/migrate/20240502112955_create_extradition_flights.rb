class CreateExtraditionFlight < ActiveRecord::Migration[7.0]
  def change
    create_table :extradition_flights, id: :uuid do |t|
      t.string :flight_number, null: false
      t.datetime :flight_time, null: false
      t.references :move, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
