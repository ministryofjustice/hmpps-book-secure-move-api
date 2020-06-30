class AddEstateToAllocations < ActiveRecord::Migration[6.0]
  def change
    add_column :allocations, :estate, :string
  end
end
