class GenericEvent
  class JourneyUncancel < GenericEvent
    eventable_types 'Journey'

    def trigger
      eventable.uncancel
    end
  end
end
