class AddDiscardedAtToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :discarded_at, :datetime
    add_index :documents, :discarded_at
  end
end
