# frozen_string_literal: true

class JourneySerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :billable, :state
  attribute :client_timestamp, key: :timestamp

  has_one :from_location, serializer: LocationSerializer
  has_one :to_location, serializer: LocationSerializer
end
