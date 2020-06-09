# frozen_string_literal: true

class PrisonTransferReason < ApplicationRecord
  has_many :moves, dependent: :nullify

  # TODO: Add index for validation
  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :key, presence: true, uniqueness: true
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  validates :title, presence: true

  scope :ordered_by_title, ->(direction) { order('prison_transfer_reasons.title' => direction) }
end
