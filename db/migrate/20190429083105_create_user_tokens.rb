class CreateUserTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :user_tokens, id: :uuid do |t|
      t.string :access_token, null: false
      t.string :refresh_token, null: false
      t.string :user_name, null: false
      t.string :user_id, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
  end
end
