class CreateSuppliers < ActiveRecord::Migration[5.2]
  def change
    create_table :suppliers, id: :uuid do |t|
      t.string :name, null: false
      t.string :key, null: false, index: true
      t.timestamps
    end
  end
end
