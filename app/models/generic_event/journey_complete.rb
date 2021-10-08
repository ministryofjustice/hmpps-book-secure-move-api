class GenericEvent
  class JourneyComplete < GenericEvent
    details_attributes :vehicle_reg
    eventable_types 'Journey'
    validate_occurs_before 'GenericEvent::MoveComplete'
    validate_occurs_after 'GenericEvent::JourneyStart'

    def trigger(*)
      if vehicle_reg.present?
        eventable.vehicle_registration = vehicle_reg
      else
        Sentry.capture_message("#{self.class} created without vehicle_reg", level: 'warning', extra: { supplier: supplier&.key })
      end

      eventable.complete
    end
  end
end
