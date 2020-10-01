module GenericEvents
  class Runner
    def initialize(eventable)
      @eventable = eventable
    end

    def call
      @eventable.generic_events.applied_order.each(&:trigger)
      @eventable.handle_event_run
    end
  end
end
