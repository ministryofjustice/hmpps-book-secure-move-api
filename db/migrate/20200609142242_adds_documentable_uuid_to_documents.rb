class AddsDocumentableUuidToDocuments < ActiveRecord::Migration[6.0]
  def change
    remove_column :documents, :documentable_id, :bigint
    add_column :documents, :documentable_id, :uuid
    add_index :documents, %i[documentable_type documentable_id]
  end
end
