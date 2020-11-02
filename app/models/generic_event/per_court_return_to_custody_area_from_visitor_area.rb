class GenericEvent
  class PerCourtReturnToCustodyAreaFromVisitorArea < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :court_cell_number
    relationship_attributes location_id: :locations

    include PersonEscortRecordEventValidations
    include LocationValidations
  end
end
