class AddPrefilledToFrameworkResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :framework_responses, :prefilled, :boolean, default: false, null: false
  end
end
