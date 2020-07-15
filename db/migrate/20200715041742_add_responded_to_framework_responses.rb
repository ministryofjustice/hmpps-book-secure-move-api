class AddRespondedToFrameworkResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :framework_responses, :responded, :boolean, null: false, default: false
  end
end
