class AddKeyToReferenceTables < ActiveRecord::Migration[5.2]
  def change
    add_column :assessment_questions, :key, :string, null: false
    rename_column :ethnicities, :code, :key
    add_column :genders, :key, :string, null: false
    add_column :locations, :key, :string, null: false
    add_column :nationalities, :key, :string, null: false
  end
end
