# frozen_string_literal: true

class FastJsonapi::LocationSerializer
  include FastJsonapi::ObjectSerializer

  set_type 'locations'

  attributes :key, :title, :location_type, :nomis_agency_id, :can_upload_documents, :disabled_at

  attribute :suppliers do |location|
    location.suppliers.each { |supplier| FastJsonapi::SupplierSerializer.new(supplier) }
  end
end
