class GenericEvent
  class JourneyExitThroughOuterGate < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :vehicle_reg
    relationship_attributes location_id: :locations
    eventable_types 'Journey'

    include LocationValidations
    include LocationFeed

    def trigger(*)
      if vehicle_reg.blank?
        Sentry.capture_message("#{self.class} created without vehicle_reg", level: 'warning', extra: { supplier: supplier&.key })
      end
    end
  end
end
