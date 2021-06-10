class AddCsraToProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :profiles, :csra, :string
  end
end
