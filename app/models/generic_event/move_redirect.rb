class GenericEvent
  class MoveRedirect < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :to_location_id

    details_attributes :move_type, :reason
    relationship_attributes to_location_id: :locations
    eventable_types 'Move'

    attribute :reason, :string
    enum reason: {
      no_space: 'no_space',
      serious_incident: 'serious_incident',
      covid: 'covid',
      receiving_prison_request: 'receiving_prison_request',
      force_majeure: 'force_majeure',
      other: 'other',
    }

    include LocationValidations
    include LocationFeed

    validates :reason, inclusion: { in: reasons }, if: -> { reason.present? }
    validates_with Moves::MoveTypeValidator

    delegate :from_location, to: :eventable
    delegate :generic_events, to: :eventable

    def trigger(*)
      eventable.to_location = to_location
      eventable.move_type = move_type if move_type.present?
    end
  end
end
