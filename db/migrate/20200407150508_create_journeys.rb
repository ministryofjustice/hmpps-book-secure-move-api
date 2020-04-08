class CreateJourneys < ActiveRecord::Migration[5.2]
  def change
    create_table :journeys, id: :uuid do |t|
      t.references :move, type: :uuid, null: false, index: true, foreign_key: true
      t.references :supplier, type: :uuid, null: false, index: true, foreign_key: true
      t.references :from_location, type: :uuid, null: false, index: true, foreign_key: {to_table: :locations}
      t.references :to_location, type: :uuid, null: false, index: true, foreign_key: {to_table: :locations}
      t.boolean :billable, null: false, default: false
      t.boolean :completed, null: false, default: false
      t.boolean :cancelled, null: false, default: false
      t.jsonb :details
      t.datetime :client_timestamp, null: false, index: true # this is provided by the supplier
      t.timestamps # these are maintained by the system and are distinct from client_timestamp
    end
  end
end
