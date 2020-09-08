class GenericEvent
  class JourneyUncancel < GenericEvent
    include JourneyEventValidations

    def trigger
      eventable.uncancel
    end
  end
end
