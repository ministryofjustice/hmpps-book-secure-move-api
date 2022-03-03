class GenericEvent
  class PerCourtAssignCellInCustody < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :court_cell_number
    relationship_attributes location_id: :locations
    eventable_types 'PersonEscortRecord'

    include CourtCellValidations
    include LocationValidations
  end
end
