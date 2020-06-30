class CreateFrameworkQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :framework_questions, id: :uuid do |t|
      t.references :framework, type: :uuid, null: false, index: true, foreign_key: true
      t.string :key, null: false
      t.string "section", null: false
      t.boolean "required", default: false, null: false
      t.string "question_type", null: false
      t.string "options", array: true, default: []
      t.string "dependent_value"
      t.boolean "followup_comment", default: false, null: false
      t.string "followup_comment_options", array: true, default: []
      t.references :parent, type: :uuid, index: true

      t.timestamps
    end
  end
end
