class GenericEvent
  class JourneyStart < GenericEvent
    include JourneyEventValidations

    def trigger
      eventable.start
    end
  end
end
