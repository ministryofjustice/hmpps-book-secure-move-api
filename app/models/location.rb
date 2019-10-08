# frozen_string_literal: true

class Location < ApplicationRecord
  LOCATION_TYPE_COURT = 'court'
  LOCATION_TYPE_POLICE = 'police'
  LOCATION_TYPE_PRISON = 'prison'

  NOMIS_AGENCY_TYPES = {
    'INST' => LOCATION_TYPE_PRISON,
    'CRT' => LOCATION_TYPE_COURT
  }.freeze

  has_and_belongs_to_many :suppliers
  has_many :moves_from, class_name: 'Move', foreign_key: :from_location_id
  has_many :moves_to, class_name: 'Move', foreign_key: :to_location_id

  validates :key, presence: true
  validates :title, presence: true
  validates :location_type, presence: true

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
