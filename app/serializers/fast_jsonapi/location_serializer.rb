# frozen_string_literal: true

class FastJsonapi::LocationSerializer
  include FastJsonapi::ObjectSerializer

  has_many :suppliers, serializer: FastJsonapi::SupplierSerializer

  set_type 'locations'

  attributes :id, :key, :title, :location_type, :nomis_agency_id, :can_upload_documents, :disabled_at
end
