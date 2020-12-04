class GenericEvent
  class JourneyStart < GenericEvent
    eventable_types 'Journey'

    def trigger
      eventable.start
    end
  end
end
