class RenameProfilesEthnicCodeId < ActiveRecord::Migration[5.2]
  def change
    rename_column :profiles, :ethnic_code_id, :ethnicity_id
  end
end
