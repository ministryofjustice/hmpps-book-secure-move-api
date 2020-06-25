# frozen_string_literal: true

class JourneySerializer < ActiveModel::Serializer
  attributes :id, :state, :billable, :vehicle
  attribute :client_timestamp, key: :timestamp

  has_one :from_location
  has_one :to_location

  SUPPORTED_RELATIONSHIPS = %w[
    from_location
    from_location.suppliers
    to_location
    to_location.suppliers
  ].freeze
end
