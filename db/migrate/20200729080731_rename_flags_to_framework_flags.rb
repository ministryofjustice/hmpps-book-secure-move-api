class RenameFlagsToFrameworkFlags < ActiveRecord::Migration[6.0]
  def change
    rename_table :flags, :framework_flags
    rename_table :flags_framework_responses, :framework_flags_responses
    rename_column :framework_flags_responses, :flag_id, :framework_flag_id
  end
end
