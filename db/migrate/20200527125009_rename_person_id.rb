class RenamePersonId < ActiveRecord::Migration[5.2]
  def change
    rename_column :moves, :person_id, :person_id_backup
  end
end
