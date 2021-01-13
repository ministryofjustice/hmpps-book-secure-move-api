class AddUniqueIndexOnYouthRiskAssessment < ActiveRecord::Migration[6.0]
  def change
    remove_index :youth_risk_assessments, :profile_id
    add_index :youth_risk_assessments, :profile_id, unique: true
  end
end
