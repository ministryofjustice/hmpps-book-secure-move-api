class AddUserTypeToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :user_type, :string
  end
end
