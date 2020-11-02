class AddSupplierIdToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :supplier_id, :string
  end
end
