# frozen_string_literal: true

class PersonSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :first_names,
    :last_name,
    :date_of_birth,
    :risk_alerts,
    :health_alerts,
    :court_information,
    :identifiers
  )

  has_one :ethnicity, serializer: EthnicitySerializer
  has_one :gender, serializer: GenderSerializer

  # has_many :risk_alerts, serializer: ProfileAttributeSerializer

  def first_names
    object.latest_profile&.first_names
  end

  def last_name
    object.latest_profile&.last_name
  end

  def date_of_birth
    object.latest_profile&.date_of_birth
  end

  def ethnicity
    object.latest_profile&.ethnicity
  end

  def gender
    object.latest_profile&.gender
  end

  def risk_alerts
    object.latest_profile&.profile_attributes&.select(&:risk_alert?) || []
  end

  def health_alerts
    object.latest_profile&.profile_attributes&.select(&:health_alert?) || []
  end

  def court_information
    object.latest_profile&.profile_attributes&.select(&:court_information?) || []
  end

  def identifiers
    object.latest_profile&.profile_identifiers || []
  end
end
