class AddHandoverOccurredAtToPersonEscortRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :person_escort_records, :handover_occurred_at, :datetime
  end
end
