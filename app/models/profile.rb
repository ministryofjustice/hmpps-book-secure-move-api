# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :person
  belongs_to :ethnicity, optional: true
  belongs_to :gender, optional: true

  # has_many :profile_attributes

  validates :person, presence: true
  validates :last_name, presence: true
  validates :first_names, presence: true

  attribute :profile_attributes, Profile::ProfileAttributes::Type.new

  # TODO: Define ProfileAttributeSerializer
  serialize :profile_attributes, Profile::ProfileAttributeSerializer # responds to load and dump methods

  def profile_attributes=(value)
    value = Profile::ProfileAttributes.new(value)
    super
  end

  def write_attribute(name, value)
    value = Profile::ProfileAttributes.new(value) if name == :profile_attributes
    super
  end
end
