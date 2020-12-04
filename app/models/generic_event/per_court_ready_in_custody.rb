class GenericEvent
  class PerCourtReadyInCustody < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    relationship_attributes location_id: :locations

    include PersonEscortRecordEventValidations
    include LocationValidations
    include LocationFeed
  end
end
