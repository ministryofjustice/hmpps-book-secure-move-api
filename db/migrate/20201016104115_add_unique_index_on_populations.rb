class AddUniqueIndexOnPopulations < ActiveRecord::Migration[6.0]
  def change
    add_index :populations, [:location_id, :date], name: 'index_on_population_uniqueness', unique: true
  end
end
