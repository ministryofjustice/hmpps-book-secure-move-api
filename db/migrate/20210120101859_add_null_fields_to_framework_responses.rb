class AddNullFieldsToFrameworkResponses < ActiveRecord::Migration[6.0]
  def change
    change_column :framework_responses, :section, :string, null: false
    change_column :framework_responses, :value_type, :string, null: false
  end
end
