class GenericEvent
  class PerCourtReturnToCustodyAreaFromDock < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :court_cell_number
    relationship_attributes location_id: :locations
    eventable_types 'PersonEscortRecord'

    include LocationValidations
    include LocationFeed
  end
end
