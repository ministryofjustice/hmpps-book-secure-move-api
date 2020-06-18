# frozen_string_literal: true

class Supplier < ApplicationRecord
  has_and_belongs_to_many :locations
  has_many :subscriptions, dependent: :destroy

  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :name, :key, presence: true, uniqueness: true
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  before_validation :ensure_key_has_value

  def ==(other)
    key == other.key
  end

private

  def ensure_key_has_value
    self.key = name.downcase.gsub(' ', '_') if key.blank? && name.present?
  end
end
