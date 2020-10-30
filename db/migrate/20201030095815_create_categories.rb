class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :key, null: false
      t.string :title, null: false
      t.boolean :move_supported, null: false
      t.timestamps
    end
    add_index :categories, :key, unique: true

    add_reference :locations, :category, type: :uuid, foreign_key: true, index: true
    add_reference :profiles, :category, type: :uuid, foreign_key: true, index: true
  end
end
