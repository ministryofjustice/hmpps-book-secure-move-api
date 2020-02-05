class MakeSubscriptionSecretEncrypted < ActiveRecord::Migration[5.2]
  def change
    rename_column :subscriptions, :secret, :encrypted_secret
  end
end
