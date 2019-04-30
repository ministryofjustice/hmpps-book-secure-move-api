class AddUserTokenAccessTokenIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :user_tokens, :access_token, unique: true
  end
end
