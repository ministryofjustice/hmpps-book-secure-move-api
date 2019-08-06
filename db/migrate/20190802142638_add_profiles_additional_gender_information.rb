class AddProfilesAdditionalGenderInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :gender_additional_information, :string
  end
end
