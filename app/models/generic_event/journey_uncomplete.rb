class GenericEvent
  class JourneyUncomplete < GenericEvent
    include JourneyEventValidations
    def trigger
      eventable.uncomplete
    end
  end
end
