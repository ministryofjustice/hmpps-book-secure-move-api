class AddNullFieldsToPersonEscortRecords < ActiveRecord::Migration[6.0]
  def change
    change_column :person_escort_records, :move_id, :uuid, null: false
  end
end
