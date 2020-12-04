class GenericEvent
  class JourneyComplete < GenericEvent
    eventable_types 'Journey'

    def trigger
      eventable.complete
    end
  end
end
