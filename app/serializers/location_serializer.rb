# frozen_string_literal: true

class LocationSerializer < ActiveModel::Serializer
  attributes :id, :key, :title, :location_type, :location_code
end
