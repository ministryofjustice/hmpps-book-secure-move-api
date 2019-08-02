class AddProfilesAdditionalGenderInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :additional_gender_information, :string
  end
end
