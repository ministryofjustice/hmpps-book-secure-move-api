class GenericEvent
  class PerCourtAssignCellInCustody < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      court_cell_number
    ].freeze

    include PersonEscortRecordEventValidations

    validates :location_id,       presence: true
    validates :court_cell_number, presence: true

    def location_id=(location_id)
      details['location_id'] = location_id
    end

    def location_id
      details['location_id']
    end

    def court_cell_number=(court_cell_number)
      details['court_cell_number'] = court_cell_number
    end

    def court_cell_number
      details['court_cell_number']
    end
  end
end
