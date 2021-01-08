class AddValueTypeToFrameworkResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :framework_responses, :value_type, :string
  end
end
