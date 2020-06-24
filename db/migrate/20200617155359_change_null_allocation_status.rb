class ChangeNullAllocationStatus < ActiveRecord::Migration[6.0]
  def change
    change_column_null :allocations, :status, false
  end
end
