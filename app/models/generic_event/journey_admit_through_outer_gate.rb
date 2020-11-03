class GenericEvent
  class JourneyAdmitThroughOuterGate < GenericEvent
    details_attributes :vehicle_reg, :supplier_personnel_number
    eventable_types 'Journey'

    include VehicleRegValidations
  end
end
