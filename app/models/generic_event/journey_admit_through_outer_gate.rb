class GenericEvent
  class JourneyAdmitThroughOuterGate < GenericEvent
    details_attributes :vehicle_reg, :supplier_personnel_number

    include JourneyEventValidations
    include VehicleRegValidations
  end
end
