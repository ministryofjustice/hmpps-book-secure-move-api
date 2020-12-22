# frozen_string_literal: true

module V2
  class JourneysSerializer
    include JSONAPI::Serializer

    set_type :journeys

    attributes :state, :billable, :vehicle
    attribute :timestamp, &:client_timestamp
  end
end
