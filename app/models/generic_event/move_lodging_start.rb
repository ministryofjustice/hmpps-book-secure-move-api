class GenericEvent
  class MoveLodgingStart < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id
    DETAILS_ATTRIBUTES = %w[
      reason
    ].freeze

    include MoveEventValidations
    include LocationValidations

    enum reason: {
      overnight_lodging: 'overnight_lodging',
      lockout: 'lockout',
      operation_hmcts: 'operation_hmcts',
      court_cells: 'court_cells',
      operation_tornado: 'operation_tornado',
      operation_safeguard: 'operation_safeguard',
      other: 'other',
    }

    validates :reason, presence: true, inclusion: { in: reasons }

    def reason=(reason)
      details['reason'] = reason
    end

    def reason
      details['reason']
    end
  end
end
