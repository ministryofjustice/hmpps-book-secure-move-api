class GenericEvent
  class JourneyCancel < GenericEvent
    include JourneyEventValidations

    def trigger
      eventable.cancel
    end
  end
end
