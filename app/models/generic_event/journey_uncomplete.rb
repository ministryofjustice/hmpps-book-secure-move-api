class GenericEvent
  class JourneyUncomplete < GenericEvent
    eventable_types 'Journey'

    def trigger(*)
      eventable.uncomplete
    end
  end
end
