# frozen_string_literal: true

class LocationSerializer
  include JSONAPI::Serializer

  INCLUDED_ATTRIBUTES = %i[
    key
    title
    location_type
    nomis_agency_id
    can_upload_documents
    disabled_at
  ]

  set_type :locations

  attributes(*INCLUDED_ATTRIBUTES)

  has_many :suppliers

  SUPPORTED_RELATIONSHIPS = %w[suppliers].freeze
end
