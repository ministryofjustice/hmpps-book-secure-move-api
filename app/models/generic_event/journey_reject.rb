class GenericEvent
  class JourneyReject < GenericEvent
    eventable_types 'Journey'

    def trigger
      eventable.reject
    end
  end
end
