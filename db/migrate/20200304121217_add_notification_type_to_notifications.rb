class AddNotificationTypeToNotifications < ActiveRecord::Migration[5.2]
  def up
    add_column :notifications, :response_id, :uuid, null: true
    add_column :notifications, :notification_type_id, :string, index: true, null: true

    # assume all existing notifications are webhooks
    execute("UPDATE notifications SET notification_type_id='webhook' WHERE notification_type_id IS NULL")

    change_column :notifications, :notification_type_id, :string, index: true, null: false
    add_foreign_key :notifications, :notification_types
  end

  def down
    if execute("SELECT COUNT(1) AS count FROM notifications WHERE notification_type_id='email'").first['count'] > 0
      raise ActiveRecord::IrreversibleMigration.new('There are notification records which have notification_type=email: please manually fix these before rolling back')
    end

    remove_foreign_key :notifications, :notification_types
    remove_column :notifications, :notification_type_id
    remove_column :notifications, :response_id
  end
end
