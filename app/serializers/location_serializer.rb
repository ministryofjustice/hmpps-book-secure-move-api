# frozen_string_literal: true

class LocationSerializer < ActiveModel::Serializer
  type 'locations'

  attributes :key,
             :title,
             :location_type,
             :nomis_agency_id,
             :can_upload_documents,
             :disabled_at

  has_many :suppliers, serializer: SupplierSerializer

  SUPPORTED_RELATIONSHIPS = %w[suppliers].freeze
end
