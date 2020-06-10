class AddsDocumentableUuidToDocuments < ActiveRecord::Migration[6.0]
  def change
    remove_column :documents, :documentable_id
    add_column :documents, :documentable_id, :uuid
  end
end
