class GenericEvent
  class JourneyAdmitThroughOuterGate < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    relationship_attributes location_id: :locations
    details_attributes :vehicle_reg, :supplier_personnel_number
    eventable_types 'Journey'

    include VehicleRegValidations
    include LocationValidations
    include LocationFeed
  end
end
