class AddHandoverDetailsToPersonEscortRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :person_escort_records, :handover_details, :jsonb, default: {}, null: false
  end
end
