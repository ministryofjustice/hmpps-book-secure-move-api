class RemoveAssessmentQuestionsNomisCode < ActiveRecord::Migration[5.2]
  def change
    remove_column :assessment_questions, :nomis_alert_code
    remove_column :assessment_questions, :nomis_alert_type
  end
end
