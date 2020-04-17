class RenameCourtTypeToCaseTypeInCourtHearing < ActiveRecord::Migration[5.2]
  def up
    if column_exists? :court_hearings, :court_type
      rename_column :court_hearings, :court_type, :case_type
    end
  end

  def down
    rename_column :court_hearings, :case_type, :court_type
  end
end
