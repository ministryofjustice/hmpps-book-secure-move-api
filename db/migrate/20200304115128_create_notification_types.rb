class CreateNotificationTypes < ActiveRecord::Migration[5.2]
  def up
    create_table :notification_types, id: :string do |t|
      t.string :title, null: false
    end

    # NB: generally its bad practice to insert data in a migration... but this table can be guaranteed to be empty as we've just created it :p
    execute "INSERT INTO notification_types(id, title) VALUES('webhook', 'Webhook');"
    execute "INSERT INTO notification_types(id, title) VALUES('email', 'Email');"
  end

  def down
    drop_table :notification_types
  end
end
