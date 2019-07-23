# Frozen_string_literal: true

class LocationSerializer < ActiveModel::Serializer
  attributes :id, :key, :title, :location_type, :nomis_agency_id, :disabled_at
end
