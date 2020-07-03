class CreateFrameworkResponsesFlags < ActiveRecord::Migration[6.0]
  def change
    create_table :framework_responses_flags, id: :uuid do |t|
      t.belongs_to :flag
      t.belongs_to :framework_response
    end
  end
end
