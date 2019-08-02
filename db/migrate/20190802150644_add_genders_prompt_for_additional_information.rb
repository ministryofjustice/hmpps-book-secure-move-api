class AddGendersPromptForAdditionalInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :genders, :prompt_for_additional_information, :boolean, null: false, default: false
  end
end
