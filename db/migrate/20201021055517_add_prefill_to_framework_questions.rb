class AddPrefillToFrameworkQuestions < ActiveRecord::Migration[6.0]
  def change
    add_column :framework_questions, :prefill, :boolean
  end
end
