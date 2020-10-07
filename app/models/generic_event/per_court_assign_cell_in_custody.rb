class GenericEvent
  class PerCourtAssignCellInCustody < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      court_cell_number
    ].freeze

    include PersonEscortRecordEventValidations
    include CourtCellValidations

    validates :location_id, presence: true

    def location_id=(location_id)
      details['location_id'] = location_id
    end

    def location_id
      details['location_id']
    end
  end
end
