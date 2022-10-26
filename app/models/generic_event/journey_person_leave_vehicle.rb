class GenericEvent
  class JourneyPersonLeaveVehicle < GenericEvent
    details_attributes :vehicle_reg
    eventable_types 'Journey'

    def trigger(dry_run: false)
      if vehicle_reg.blank? && !dry_run
        Sentry.capture_message("#{self.class} created without vehicle_reg", level: 'warning', extra: { supplier: supplier&.key })
      end
    end
  end
end
