class GenericEvent
  class JourneyAdmitToReception < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :vehicle_reg
    relationship_attributes location_id: :locations
    eventable_types 'Journey'

    include LocationValidations
    include LocationFeed

    def trigger(dry_run: false)
      if vehicle_reg.blank? && !dry_run
        Sentry.capture_message("#{self.class} created without vehicle_reg", level: 'warning', extra: { supplier: supplier&.key })
      end
    end
  end
end
