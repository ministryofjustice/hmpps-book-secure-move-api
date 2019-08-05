# frozen_string_literal: true

class Gender < ApplicationRecord
  validates :title, presence: true
  validates :key, presence: true
  validates :prompt_for_additional_information, inclusion: [true, false]

  before_validation :set_prompt_for_additional_information

  private

  def set_prompt_for_additional_information
    self.prompt_for_additional_information = false if prompt_for_additional_information.nil?
  end
end
