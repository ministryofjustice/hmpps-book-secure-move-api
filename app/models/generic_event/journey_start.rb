class GenericEvent
  class JourneyStart < GenericEvent
    details_attributes :vehicle_reg
    eventable_types 'Journey'

    def trigger(*)
      if vehicle_reg.present?
        eventable.vehicle_registration = vehicle_reg
      else
        Sentry.capture_message("#{self.class} created without vehicle_reg", level: 'warning', extra: { supplier: supplier&.key })
      end

      eventable.start
    end
  end
end
