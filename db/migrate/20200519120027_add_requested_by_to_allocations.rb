class AddRequestedByToAllocations < ActiveRecord::Migration[5.2]
  def change
    add_column :allocations, :requested_by, :string
  end
end
