class GenericEvent
  class JourneyLockout < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :from_location_id

    relationship_attributes from_location_id: :locations
    eventable_types 'Journey'

    include LocationValidations
  end
end
