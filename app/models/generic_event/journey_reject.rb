class GenericEvent
  class JourneyReject < GenericEvent
    include JourneyEventValidations

    def trigger
      eventable.reject
    end
  end
end
