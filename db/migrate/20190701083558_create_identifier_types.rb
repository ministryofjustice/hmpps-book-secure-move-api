class CreateIdentifierTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :identifier_types, id: :string do |t|
      t.string "title", null: false
      t.string "description"
    end
  end
end
