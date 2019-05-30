# frozen_string_literal: true

class ProfileAttribute < ApplicationRecord
  validates :description, presence: true
  validates :profile, presence: true
  validates :profile_attribute_type, presence: true

  belongs_to :profile
  belongs_to :profile_attribute_type

  def risk?
    profile_attribute_type&.category == ProfileAttributeType.categories[:risk]
  end

  def health?
    profile_attribute_type&.category == ProfileAttributeType.categories[:health]
  end

  def court_information?
    profile_attribute_type&.category == ProfileAttributeType.categories[:court_information]
  end
end
