class AddClassificationToGenericEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :generic_events, :classification, :string, default: 'default'
    add_index :generic_events, [:eventable_id, :eventable_type, :classification], name: 'index_on_generic_event_classification'
  end
end
