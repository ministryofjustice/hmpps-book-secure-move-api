class AddAssessmentDatesToFrameworkNomisMapping < ActiveRecord::Migration[6.0]
  def change
    add_column :framework_nomis_mappings, :approval_date, :date
    add_column :framework_nomis_mappings, :next_review_date, :date
  end
end
