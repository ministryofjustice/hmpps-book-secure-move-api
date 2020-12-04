class RemovePersonEscortRecordFromFrameworkResponses < ActiveRecord::Migration[6.0]
  def change
    remove_column :framework_responses, :person_escort_record_id
  end
end
