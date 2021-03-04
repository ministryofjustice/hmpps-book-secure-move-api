class GenericEvent
  class JourneyCancel < GenericEvent
    eventable_types 'Journey'

    def trigger(*)
      eventable.cancel
    end
  end
end
