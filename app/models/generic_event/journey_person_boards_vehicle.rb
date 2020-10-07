class GenericEvent
  class JourneyPersonBoardsVehicle < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      vehicle_type
      vehicle_reg
    ].freeze

    include JourneyEventValidations
    include VehicleTypeValidations
    include VehicleRegValidations
  end
end
