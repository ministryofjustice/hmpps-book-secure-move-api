# frozen_string_literal: true

class Supplier < ApplicationRecord
  has_and_belongs_to_many :locations
  has_many :subscriptions, dependent: :destroy

  validates :name, :key, presence: true, uniqueness: true
  before_validation :ensure_key_has_value

private

  def ensure_key_has_value
    self.key = name.downcase.gsub(' ', '_') if key.blank? && name.present?
  end
end
