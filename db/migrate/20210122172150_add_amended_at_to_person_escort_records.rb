class AddAmendedAtToPersonEscortRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :person_escort_records, :amended_at, :datetime
  end
end
