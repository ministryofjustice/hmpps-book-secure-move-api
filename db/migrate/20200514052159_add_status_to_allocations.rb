class AddStatusToAllocations < ActiveRecord::Migration[5.2]
  def change
    add_column :allocations, :status, :string
  end
end
