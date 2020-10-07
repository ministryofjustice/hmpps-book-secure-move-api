class GenericEvent
  class PerCourtAssignCellInCustody < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id
    DETAILS_ATTRIBUTES = %w[
      court_cell_number
    ].freeze

    include PersonEscortRecordEventValidations
    include CourtCellValidations
    include LocationValidations
  end
end
