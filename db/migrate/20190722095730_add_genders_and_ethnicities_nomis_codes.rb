class AddGendersAndEthnicitiesNomisCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :genders, :nomis_code, :string
    add_column :ethnicities, :nomis_code, :string
  end
end
