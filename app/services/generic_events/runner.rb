module GenericEvents
  class Runner
    def initialize(eventable)
      @eventable = eventable
    end

    def call(dry_run: false)
      @eventable.generic_events.applied_order.each { |e| e.trigger({ dry_run: dry_run }) }
      @eventable.handle_event_run unless dry_run
    end
  end
end
