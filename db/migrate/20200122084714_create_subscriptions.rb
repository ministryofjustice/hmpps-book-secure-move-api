class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.references :supplier, foreign_key: true, null: false, type: :uuid
      t.string :topic, null: false, default: '*'
      t.string :callback, null: false, index: true
      t.string :username
      t.string :password
      t.string :secret
      t.boolean :enabled, null: false, default: true

      t.timestamps
    end
  end
end
