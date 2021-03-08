class GenericEvent
  class JourneyChangeVehicle < GenericEvent
    details_attributes :vehicle_reg, :previous_vehicle_reg
    eventable_types 'Journey'

    include VehicleRegValidations

    validates :previous_vehicle_reg, presence: true

    def trigger(*)
      eventable.vehicle_registration = vehicle_reg
    end
  end
end
