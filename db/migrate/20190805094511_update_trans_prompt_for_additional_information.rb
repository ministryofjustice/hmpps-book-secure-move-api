class UpdateTransPromptForAdditionalInformation < ActiveRecord::Migration[5.2]
  def change
    Gender.find_by(key: 'trans')&.update(prompt_for_additional_information: true)
  end
end
