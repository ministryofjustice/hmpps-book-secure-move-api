class AddCategoryToProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :profiles, :category, :string, null: true
    add_column :profiles, :category_code, :string, null: true
    add_index :profiles, :category_code
  end
end
