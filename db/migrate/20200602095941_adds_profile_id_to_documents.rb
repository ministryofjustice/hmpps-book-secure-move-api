class AddsProfileIdToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :profile, type: :uuid
  end
end
