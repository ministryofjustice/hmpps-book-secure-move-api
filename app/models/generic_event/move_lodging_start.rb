class GenericEvent
  class MoveLodgingStart < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      reason
    ].freeze

    include MoveEventValidations

    enum reason: {
      overnight_lodging: 'overnight_lodging',
      lockout: 'lockout',
      operation_hmcts: 'operation_hmcts',
      court_cells: 'court_cells',
      operation_tornado: 'operation_tornado',
      operation_safeguard: 'operation_safeguard',
      other: 'other',
    }

    validates :reason,      presence: true, inclusion: { in: reasons }
    validates :location_id, presence: true

    def reason=(reason)
      details['reason'] = reason
    end

    def reason
      details['reason']
    end

    def location_id=(location_id)
      details['location_id'] = location_id
    end

    def location_id
      details['location_id']
    end
  end
end