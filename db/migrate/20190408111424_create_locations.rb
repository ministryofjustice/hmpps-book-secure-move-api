class CreateLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations, id: :uuid do |t|
      t.string :label, null: false
      t.string :description
      t.string :location_type
      t.timestamps
    end

    add_foreign_key :moves, :locations, column: :from_location_id, name: :fk_rails_moves_from_location_id
    add_foreign_key :moves, :locations, column: :to_location_id, name: :fk_rails_moves_to_location_id
  end
end
