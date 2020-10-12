class GenericEvent
  class PerCourtReturnToCustodyAreaFromVisitorArea < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id
    DETAILS_ATTRIBUTES = %w[
      court_cell_number
    ].freeze

    include PersonEscortRecordEventValidations
    include LocationValidations

    def court_cell_number=(court_cell_number)
      details['court_cell_number'] = court_cell_number
    end

    def court_cell_number
      details['court_cell_number']
    end
  end
end
