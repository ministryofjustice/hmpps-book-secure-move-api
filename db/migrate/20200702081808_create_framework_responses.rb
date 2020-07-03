class CreateFrameworkResponses < ActiveRecord::Migration[6.0]
  def change
    create_table :framework_responses, id: :uuid do |t|
      t.references :person_escort_record, type: :uuid, null: false, index: true, foreign_key: true
      t.references :framework_question, type: :uuid, null: false, index: true, foreign_key: true
      t.text :value_text
      t.jsonb :value_json
      t.string "value_type", null: false
      t.references :parent, type: :uuid, index: true

      t.timestamps
    end

    add_index  :framework_responses, :value_json, using: :gin
  end
end
