class CreateAllocations < ActiveRecord::Migration[5.2]
  def change
    create_table :allocations, id: :uuid do |t|
      t.uuid :from_location_id, null: false
      t.uuid :to_location_id, null: false
      t.date :date, null: false, index: true
      t.string :prisoner_category
      t.string :sentence_length
      t.jsonb :complex_cases
      t.integer :moves_count, null: false
      t.boolean :complete_in_full, default: false, null: false
      t.text :other_criteria
      t.timestamps
    end

    add_foreign_key :allocations, :locations, column: :from_location_id, name: :fk_rails_allocations_from_location_id
    add_foreign_key :allocations, :locations, column: :to_location_id, name: :fk_rails_allocations_to_location_id
  end
end
