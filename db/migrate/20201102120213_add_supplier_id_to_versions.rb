class AddSupplierIdToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :supplier_id, :uuid, null: true
    add_foreign_key :versions, :suppliers, column: :supplier_id
  end
end
