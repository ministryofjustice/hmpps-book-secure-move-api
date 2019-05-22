# frozen_string_literal: true

class LocationSerializer < ActiveModel::Serializer
  attributes :id, :description, :location_type, :location_code
end
