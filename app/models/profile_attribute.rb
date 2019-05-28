# frozen_string_literal: true

class ProfileAttribute < ApplicationRecord
  validates :description, presence: true
  validates :profile, presence: true
  validates :profile_attribute_type, presence: true

  belongs_to :profile
  belongs_to :profile_attribute_type
end
