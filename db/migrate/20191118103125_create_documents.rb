class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents, id: :uuid do |t|
      t.string :document_type, null: false
      t.text :description
      t.references :move, type: :uuid, null: false, index: true, foreign_key: true
      t.timestamps
    end
  end
end
