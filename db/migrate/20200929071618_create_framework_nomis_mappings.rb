class CreateFrameworkNomisMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :framework_nomis_mappings, id: :uuid do |t|
      t.jsonb :raw_nomis_mapping, null: false
      t.string :code, null: false
      t.string :type, null: false
      t.text :code_description
      t.text :comments
      t.date :start_date
      t.date :end_date
      t.date :creation_date
      t.date :expiry_date

      t.timestamps
    end
  end
end
