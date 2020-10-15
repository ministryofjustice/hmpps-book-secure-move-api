class GenericEvent
  class JourneyChangeVehicle < GenericEvent
    before_create :set_previous_vehicle_registration

    details_attributes :vehicle_reg, :previous_vehicle_reg

    include JourneyEventValidations
    include VehicleRegValidations

    def trigger
      eventable.vehicle_registration = vehicle_reg
    end

  private

    def set_previous_vehicle_registration
      self.previous_vehicle_reg = eventable.vehicle_registration
    end
  end
end
