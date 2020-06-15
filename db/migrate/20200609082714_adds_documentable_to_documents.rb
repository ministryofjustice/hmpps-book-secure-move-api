class AddsDocumentableToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_reference :documents, :documentable, polymorphic: true, index: true
  end
end
