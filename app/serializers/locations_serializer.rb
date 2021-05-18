# frozen_string_literal: true

class LocationsSerializer
  include JSONAPI::Serializer

  set_type :locations

  attributes :key,
             :title,
             :location_type,
             :nomis_agency_id,
             :can_upload_documents,
             :young_offender_institution,
             :premise,
             :locality,
             :city,
             :country,
             :postcode,
             :latitude,
             :longitude,
             :created_at,
             :disabled_at
end
