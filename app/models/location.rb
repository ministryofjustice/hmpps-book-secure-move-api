# frozen_string_literal: true

class Location < ApplicationRecord
  LOCATION_TYPE_COURT = 'court'
  LOCATION_TYPE_POLICE = 'police'
  LOCATION_TYPE_PRISON = 'prison'
  LOCATION_TYPE_SECURE_TRAINING_CENTER = 'secure_training_centre'
  LOCATION_TYPE_SECURE_CHILDRENS_HOME = 'secure_childrens_home'
  LOCATION_TYPE_YOUTH_OFFENDNG_INSTITUTE = 'youth_offending_institute'

  NOMIS_AGENCY_TYPES = {
    'INST' => LOCATION_TYPE_PRISON,
    'CRT' => LOCATION_TYPE_COURT,
    'POLICE' => LOCATION_TYPE_POLICE,
    'STC' => LOCATION_TYPE_SECURE_TRAINING_CENTER,
    'SCH' => LOCATION_TYPE_SECURE_CHILDRENS_HOME,
    'YOI' => LOCATION_TYPE_YOUTH_OFFENDNG_INSTITUTE,
  }.freeze

  NOMIS_TYPES_WITH_DOCUMENTS = %w[STC SCH].freeze

  has_and_belongs_to_many :suppliers
  # Deleting locations isn't really a thing in practice - so dependent: :destroy is a pragmatic choice
  has_many :moves_from, class_name: 'Move', foreign_key: :from_location_id, inverse_of: :from_location, dependent: :destroy
  has_many :moves_to, class_name: 'Move', foreign_key: :to_location_id, inverse_of: :to_location, dependent: :destroy

  validates :key, presence: true
  validates :title, presence: true
  validates :location_type, presence: true

  scope :supplier, ->(supplier_id) { joins(:suppliers).where(locations_suppliers: { supplier_id: supplier_id }) }

  scope :ordered_by_title, ->(direction) { order('locations.title' => direction) }

  def prison?
    location_type.to_s == LOCATION_TYPE_PRISON
  end

  def police?
    location_type.to_s == LOCATION_TYPE_POLICE
  end

  def court?
    location_type.to_s == LOCATION_TYPE_COURT
  end
end
