class RemoveNotificationTimestamp < ActiveRecord::Migration[5.2]
  def change
    remove_column :notifications, :time_stamp
  end
end
