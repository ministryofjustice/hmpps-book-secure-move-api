class AddStatusToLodgings < ActiveRecord::Migration[7.0]
  def change
    add_column :lodgings, :status, :string, null: false, index: true, default: 'proposed'
  end
end
