class GenericEvent
  class MoveLodgingStart < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :reason
    relationship_attributes location_id: :locations
    eventable_types 'Move'

    include LocationValidations
    include LocationFeed

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
  end
end
