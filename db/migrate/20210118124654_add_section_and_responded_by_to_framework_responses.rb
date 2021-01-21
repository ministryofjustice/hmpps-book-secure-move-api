class AddSectionAndRespondedByToFrameworkResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :framework_responses, :section, :string
    add_column :framework_responses, :responded_by, :string
    add_column :framework_responses, :responded_at, :datetime
  end
end
