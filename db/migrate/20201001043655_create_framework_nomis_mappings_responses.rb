class CreateFrameworkNomisMappingsResponses < ActiveRecord::Migration[6.0]
  def change
    create_table :framework_nomis_mappings_responses, id: :uuid do |t|
      t.uuid :framework_response_id
      t.uuid :framework_nomis_mapping_id
    end

    add_index :framework_nomis_mappings_responses, :framework_response_id, name: 'index_framework_nomis_mappings_responses_on_response_id'
    add_index :framework_nomis_mappings_responses, :framework_nomis_mapping_id, name: 'index_framework_nomis_mappings_responses_on_nomis_mapping_id'
  end
end
