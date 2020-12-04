class AddNomisSyncStatusToPersonEscortRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :person_escort_records, :nomis_sync_status, :jsonb, default: [], null: false
  end
end
