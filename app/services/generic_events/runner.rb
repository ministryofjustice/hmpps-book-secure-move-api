module GenericEvents
  class Runner
    attr_reader :eventable, :dry_run

    def initialize(eventable, dry_run: false)
      @eventable = eventable
      @dry_run = dry_run
    end

    def call(&block)
      if dry_run
        eventable.transaction do
          trigger_events(&block)

          raise ActiveRecord::Rollback
        end
      else
        trigger_events(&block)
      end
    end

  private

    def trigger_events
      eventable.generic_events.applied_order.each do |event|
        event.trigger(dry_run: dry_run)
        yield event if block_given?
      end

      eventable.handle_event_run(dry_run: dry_run)
    end
  end
end
