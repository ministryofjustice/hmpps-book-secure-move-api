class GenericEvent
  class JourneyPersonLeaveVehicle < GenericEvent
    details_attributes :vehicle_reg
    eventable_types 'Journey'

    def trigger(*)
      if vehicle_reg.blank?
        Sentry.capture_message("#{self.class} created without vehicle_reg", level: 'warning', extra: { supplier: supplier&.key })
      end
    end
  end
end
