class RenameProfileForenamesAndSurname < ActiveRecord::Migration[5.2]
  def change
    rename_column :profiles, :forenames, :first_names
    rename_column :profiles, :surname, :last_name
  end
end
