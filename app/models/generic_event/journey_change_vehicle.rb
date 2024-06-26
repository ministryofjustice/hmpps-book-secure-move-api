class GenericEvent
  class JourneyChangeVehicle < GenericEvent
    details_attributes :vehicle_reg, :previous_vehicle_reg, :vehicle_depot
    eventable_types 'Journey'

    include VehicleRegValidations

    validates :previous_vehicle_reg, presence: true

    def trigger(*)
      eventable.vehicle_registration = vehicle_reg

      if vehicle_depot.present?
        eventable.vehicle_depot = vehicle_depot
      end
    end
  end
end
