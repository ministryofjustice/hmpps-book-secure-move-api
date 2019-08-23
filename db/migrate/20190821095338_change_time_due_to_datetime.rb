class ChangeTimeDueToDatetime < ActiveRecord::Migration[5.2]
  def change
    remove_column :moves, :time_due
    add_column :moves, :time_due, :datetime
  end
end
