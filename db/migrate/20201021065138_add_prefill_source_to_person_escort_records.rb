class AddPrefillSourceToPersonEscortRecords < ActiveRecord::Migration[6.0]
  def change
    add_reference :person_escort_records, :prefill_source, type: :uuid, index: true, null: true
  end
end
