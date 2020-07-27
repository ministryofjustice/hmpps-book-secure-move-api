class RenameStateOnPersonEscortRecord < ActiveRecord::Migration[6.0]
    def change
    rename_column :person_escort_records, :state, :status
  end
end
