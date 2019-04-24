# frozen_string_literal: true

class LocationSerializer < ActiveModel::Serializer
  attributes :id, :label, :description, :location_type
end
