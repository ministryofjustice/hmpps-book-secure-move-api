class GenericEvent
  class MoveLodgingEnd < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    relationship_attributes :location_id

    include MoveEventValidations
    include LocationValidations
  end
end
