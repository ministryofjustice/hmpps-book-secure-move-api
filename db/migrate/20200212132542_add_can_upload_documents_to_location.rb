class AddCanUploadDocumentsToLocation < ActiveRecord::Migration[5.2]
  def change
    change_table :locations do |t|
      t.boolean :can_upload_documents, null: false, default: false
    end
  end
end
