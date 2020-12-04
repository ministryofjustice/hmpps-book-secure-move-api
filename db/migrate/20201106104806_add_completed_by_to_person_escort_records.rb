class AddCompletedByToPersonEscortRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :person_escort_records, :completed_at, :datetime
  end
end
