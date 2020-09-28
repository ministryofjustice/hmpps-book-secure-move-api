class CreateFrameworkNomisCodesQuestionsJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_table :framework_nomis_codes_questions, id: false do |t|
      t.uuid :framework_question_id
      t.uuid :framework_nomis_code_id
    end

    add_index :framework_nomis_codes_questions, :framework_question_id, name: 'index_framework_nomis_codes_questions_on_question_id'
    add_index :framework_nomis_codes_questions, :framework_nomis_code_id, name: 'index_framework_nomis_codes_questions_on_nomis_code_id'
  end
end
