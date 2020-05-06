# frozen_string_literal: true

class LocationSerializer < ActiveModel::Serializer
  type 'locations'

  attributes :id, :key, :title, :location_type, :nomis_agency_id, :can_upload_documents, :disabled_at, :suppliers
end
