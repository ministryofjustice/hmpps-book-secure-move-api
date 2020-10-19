class GenericEvent
  class JourneyPersonBoardsVehicle < GenericEvent
    details_attributes :vehicle_type, :vehicle_reg

    include JourneyEventValidations
    include VehicleTypeValidations
    include VehicleRegValidations
  end
end
