class RenameProfileAttributes < ActiveRecord::Migration[5.2]
  def change
    rename_table :profile_attribute_types, :assessment_answer_types
    remove_column :assessment_answer_types, :user_type
    rename_column :assessment_answer_types, :alert_type, :nomis_alert_type
    rename_column :assessment_answer_types, :alert_code, :nomis_alert_code
    rename_column :assessment_answer_types, :description, :title
  end
end
