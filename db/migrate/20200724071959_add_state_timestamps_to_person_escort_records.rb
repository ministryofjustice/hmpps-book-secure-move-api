class AddStateTimestampsToPersonEscortRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :person_escort_records, :confirmed_at, :datetime
  end
end
