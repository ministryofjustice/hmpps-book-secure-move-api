class AddSectionProgressToAssessments < ActiveRecord::Migration[6.0]
  def change
    add_column :person_escort_records, :section_progress, :jsonb, default: [], null: false
    add_column :youth_risk_assessments, :section_progress, :jsonb, default: [], null: false
  end
end
