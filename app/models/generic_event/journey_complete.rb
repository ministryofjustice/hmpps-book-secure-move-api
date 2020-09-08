class GenericEvent
  class JourneyComplete < GenericEvent
    include JourneyEventValidations

    def trigger
      eventable.complete
    end
  end
end
