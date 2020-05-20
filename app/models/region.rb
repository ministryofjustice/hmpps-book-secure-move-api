# frozen_string_literal: true

class Region < ApplicationRecord
  has_and_belongs_to_many :locations

  # TODO: Add index for validation
  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :name, :key, presence: true, uniqueness: true
  # rubocop:enable Rails/UniqueValidationWithoutIndex
end
