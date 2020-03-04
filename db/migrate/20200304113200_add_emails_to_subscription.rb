class AddEmailsToSubscription < ActiveRecord::Migration[5.2]
  def up
    change_column :subscriptions, :callback_url, :string, null: true
    add_column :subscriptions, :email_addresses, :string, null: true
  end

  def down
    if execute("SELECT COUNT(1) AS count FROM subscriptions WHERE callback_url IS NULL").first['count'] > 0
      raise ActiveRecord::IrreversibleMigration.new('There are subscription records which have a null callback_url: please manually fix these before rolling back')
    end

    change_column :subscriptions, :callback_url, :string, null: false
    remove_column :subscriptions, :email_addresses, :string, null: true
  end
end
