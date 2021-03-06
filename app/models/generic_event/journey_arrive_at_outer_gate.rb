class GenericEvent
  class JourneyArriveAtOuterGate < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    relationship_attributes location_id: :locations
    eventable_types 'Journey'

    include LocationValidations
    include LocationFeed
  end
end
