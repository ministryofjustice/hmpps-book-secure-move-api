class CreateProfileAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :profile_attributes, :jsonb
  end
end
