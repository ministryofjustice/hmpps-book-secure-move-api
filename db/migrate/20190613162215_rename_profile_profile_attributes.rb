class RenameProfileProfileAttributes < ActiveRecord::Migration[5.2]
  def change
    rename_column :profiles, :profile_attributes, :assessment_answers
  end
end
