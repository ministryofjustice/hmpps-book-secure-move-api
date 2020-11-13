class AddAssessmentableToFrameworkResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :framework_responses, :assessmentable_id, :uuid
    add_column :framework_responses, :assessmentable_type, :string
    add_index :framework_responses, [:assessmentable_type, :assessmentable_id], name: 'index_responses_on_assessmentable_type_and_assessmentable_id'
  end
end
