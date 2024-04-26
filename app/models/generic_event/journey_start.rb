class GenericEvent
  class JourneyStart < GenericEvent
    details_attributes :vehicle_reg, :vehicle_depot
    eventable_types 'Journey'
    validate_occurs_before 'GenericEvent::JourneyComplete'
    validate_occurs_after 'GenericEvent::MoveStart'

    def trigger(*)
      if vehicle_reg.present?
        eventable.vehicle_registration = vehicle_reg
      else
        Sentry.capture_message("#{self.class} created without vehicle_reg", level: 'warning', extra: { supplier: supplier&.key })
      end
      if vehicle_depot.present?
        eventable.vehicle_depot = vehicle_depot
      end

      eventable.start
    end
  end
end
