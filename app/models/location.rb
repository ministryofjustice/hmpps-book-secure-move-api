# frozen_string_literal: true

class Location < ApplicationRecord
  include Discard::Model
  # TODO: rename disabled_at column to discarded_at and remove this line
  self.discard_column = :disabled_at

  LOCATION_TYPE_COURT = 'court'
  LOCATION_TYPE_POLICE = 'police'
  LOCATION_TYPE_PRISON = 'prison'
  LOCATION_TYPE_SECURE_TRAINING_CENTRE = 'secure_training_centre'
  LOCATION_TYPE_SECURE_CHILDRENS_HOME = 'secure_childrens_home'
  LOCATION_TYPE_APPROVED_PREMISES = 'approved_premises'
  LOCATION_TYPE_PROBATION_OFFICE = 'probation_office'
  LOCATION_TYPE_COMMUNITY_REHABILITATION_COMPANY = 'community_rehabilitation_company'
  LOCATION_TYPE_FOREIGN_NATIONAL_PRISON = 'foreign_national_prison'
  LOCATION_TYPE_VOLUNTARY_HOSTEL = 'voluntary_hostel'
  LOCATION_TYPE_HIGH_SECURITY_HOSPITAL = 'high_security_hospital'
  LOCATION_TYPE_HOSPITAL = 'hospital'
  LOCATION_TYPE_IMMIGRATION_DETENTION_CENTRE = 'immigration_detention_centre'

  enum location_type: {
    court: LOCATION_TYPE_COURT,
    police: LOCATION_TYPE_POLICE,
    prison: LOCATION_TYPE_PRISON,
    secure_training_centre: LOCATION_TYPE_SECURE_TRAINING_CENTRE,
    secure_childrens_home: LOCATION_TYPE_SECURE_CHILDRENS_HOME,
    approved_premises: LOCATION_TYPE_APPROVED_PREMISES,
    probation_office: LOCATION_TYPE_PROBATION_OFFICE,
    community_rehabilitation_company: LOCATION_TYPE_COMMUNITY_REHABILITATION_COMPANY,
    foreign_national_prison: LOCATION_TYPE_FOREIGN_NATIONAL_PRISON,
    voluntary_hostel: LOCATION_TYPE_VOLUNTARY_HOSTEL,
    high_security_hospital: LOCATION_TYPE_HIGH_SECURITY_HOSPITAL,
    hospital: LOCATION_TYPE_HOSPITAL,
    immigration_detention_centre: LOCATION_TYPE_IMMIGRATION_DETENTION_CENTRE,
  }

  NOMIS_AGENCY_TYPES = {
    'INST' => LOCATION_TYPE_PRISON,
    'CRT' => LOCATION_TYPE_COURT,
    'POLICE' => LOCATION_TYPE_POLICE,
    'STC' => LOCATION_TYPE_SECURE_TRAINING_CENTRE,
    'SCH' => LOCATION_TYPE_SECURE_CHILDRENS_HOME,
    'APPR' => LOCATION_TYPE_APPROVED_PREMISES,
    'COMM' => LOCATION_TYPE_PROBATION_OFFICE,
    'CRC' => LOCATION_TYPE_COMMUNITY_REHABILITATION_COMPANY,
    'FNP' => LOCATION_TYPE_FOREIGN_NATIONAL_PRISON,
    'HOST' => LOCATION_TYPE_VOLUNTARY_HOSTEL,
    'HSHOSP' => LOCATION_TYPE_HIGH_SECURITY_HOSPITAL,
    'HOSPITAL' => LOCATION_TYPE_HOSPITAL,
    'IMDC' => LOCATION_TYPE_IMMIGRATION_DETENTION_CENTRE,
  }.freeze

  NOMIS_TYPES_WITH_DOCUMENTS = %w[STC SCH].freeze

  belongs_to :category, optional: true
  has_many :supplier_locations
  has_many :suppliers, through: :supplier_locations
  has_and_belongs_to_many :regions
  # Deleting locations isn't really a thing in practice - so dependent: :destroy is a pragmatic choice
  has_many :moves_from, class_name: 'Move', foreign_key: :from_location_id, inverse_of: :from_location, dependent: :destroy
  has_many :moves_to, class_name: 'Move', foreign_key: :to_location_id, inverse_of: :to_location, dependent: :destroy
  has_many :populations, dependent: :destroy

  validates :key, presence: true
  validates :title, presence: true
  validates :location_type, presence: true, inclusion: { in: location_types }

  scope :ordered_by_title, ->(direction) { order('locations.title' => direction) }
  scope :search_by_title, ->(search) { select(:id).where('title ILIKE :search', search: "%#{search}%") }

  def detained?
    prison? || secure_training_centre? || secure_childrens_home?
  end

  def not_detained?
    !detained?
  end

  def for_feed(prefix: nil)
    prefix = "#{prefix}_" if prefix

    {
      "#{prefix}location_type" => location_type,
      "#{prefix}location" => nomis_agency_id,
    }
  end

  def to_s
    "#{title} (#{nomis_agency_id} #{id})"
  end
end
