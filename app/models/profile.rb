# frozen_string_literal: true

class Profile < ApplicationRecord
  before_validation :set_profile_attributes

  belongs_to :person
  belongs_to :ethnicity, optional: true
  belongs_to :gender, optional: true

  validates :person, presence: true
  validates :last_name, presence: true
  validates :first_names, presence: true

  attribute :profile_attributes, Profile::ProfileAttributes::Type.new
  attribute :profile_identifiers, Profile::ProfileIdentifiers::Type.new

  IDENTIFIER_TYPES = %w[pnc_number cro_number prison_number niche_reference athena_reference].freeze

  private

  def set_profile_attributes
    profile_attributes.each(&:set_category_and_user_type)
  end
end
