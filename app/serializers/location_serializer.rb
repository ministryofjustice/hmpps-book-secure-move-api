# frozen_string_literal: true

class LocationSerializer
  include JSONAPI::Serializer

  set_type :locations

  attributes :key,
             :title,
             :location_type,
             :nomis_agency_id,
             :can_upload_documents,
             :disabled_at

  has_many :suppliers

  SUPPORTED_RELATIONSHIPS = %w[suppliers].freeze
end
