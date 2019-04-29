class CreateFrontEndTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :front_end_tokens, id: :uuid do |t|
      t.string :access_token, null: false
      t.string :refresh_token, null: false
      t.string :user_name, null: false
      t.string :user_email, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
  end
end
