module GenericEvents
  class Runner
    def initialize(eventable)
      @eventable = eventable
    end

    def call(dry_run: false, &block)

      if dry_run
        @eventable.transaction do

          @eventable.generic_events.applied_order.each do |event|
            event.trigger({ dry_run: dry_run })
            yield event if block_given?
          end

          raise ActiveRecord::Rollback
        end
      else
        @eventable.generic_events.applied_order.each do |event|
          event.trigger({ dry_run: dry_run })
          yield event if block_given?
        end
        @eventable.handle_event_run
      end
    end
  end
end
