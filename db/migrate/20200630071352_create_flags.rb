class CreateFlags < ActiveRecord::Migration[6.0]
  def change
    create_table :flags, id: :uuid do |t|
      t.references :framework_question, type: :uuid, null: false, index: true, foreign_key: true
      t.string :flag_type, null: false
      t.string "name", null: false
      t.string "question_value", null: false

      t.timestamps
    end
  end
end
