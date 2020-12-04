class GenericEvent
  class JourneyPersonBoardsVehicle < GenericEvent
    details_attributes :vehicle_type, :vehicle_reg
    eventable_types 'Journey'

    include VehicleTypeValidations
    include VehicleRegValidations
  end
end
