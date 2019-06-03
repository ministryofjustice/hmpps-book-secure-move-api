class AddProfilesProfileAttributes < ActiveRecord::Migration[5.2]
  def change
    drop_table :profile_attributes
    add_column :profiles, :profile_attributes, :jsonb
  end
end
