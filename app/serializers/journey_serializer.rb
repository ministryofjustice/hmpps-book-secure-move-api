# frozen_string_literal: true

class JourneySerializer < ActiveModel::Serializer
  attributes :id, :state, :billable, :vehicle
  attribute :client_timestamp, key: :timestamp

  has_one :from_location
  has_one :to_location
end
