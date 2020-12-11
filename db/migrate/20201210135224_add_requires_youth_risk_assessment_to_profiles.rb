class AddRequiresYouthRiskAssessmentToProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :profiles, :requires_youth_risk_assessment, :boolean
  end
end
