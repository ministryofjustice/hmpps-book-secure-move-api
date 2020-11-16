class ChangePersonEscortRecordToOptionalOnFrameworkResponses < ActiveRecord::Migration[6.0]
  def change
    change_column :framework_responses, :person_escort_record_id, :uuid, null: true
  end
end
