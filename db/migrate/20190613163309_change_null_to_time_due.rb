class ChangeNullToTimeDue < ActiveRecord::Migration[5.2]
  def change
    change_column_null :moves, :time_due, true
  end
end
