class RenameAssessmentAnswerTypes < ActiveRecord::Migration[5.2]
  def change
    rename_table :assessment_answer_types, :assessment_questions
  end
end
