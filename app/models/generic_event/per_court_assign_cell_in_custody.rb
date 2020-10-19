class GenericEvent
  class PerCourtAssignCellInCustody < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :court_cell_number
    relationship_attributes :location_id

    include PersonEscortRecordEventValidations
    include CourtCellValidations
    include LocationValidations
  end
end
