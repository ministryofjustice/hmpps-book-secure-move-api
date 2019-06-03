class AddProfilesProfileIdentifiers < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :profile_identifiers, :jsonb
  end
end
