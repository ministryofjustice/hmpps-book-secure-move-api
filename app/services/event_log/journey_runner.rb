module EventLog
  class JourneyRunner
    attr_reader :journey

    def initialize(journey)
      @journey = journey
    end

    # Process events in order of client_timestamp
    def call
      # iterate over all events in the log and apply changes to the journey
      events.each do |event| # NB: do not use events.find_each as it will break the ordering
        case event.event_name
        when Event::CANCEL, Event::COMPLETE, Event::REJECT, Event::START, Event::UNCANCEL, Event::UNCOMPLETE
          # with a state-changing event, delegate it to the state machine
          journey.send(event.event_name)
        when Event::LOCKOUT, Event::LODGING
          # no action to perform when a journey is locked out or lodged, these events are purely for auditing
          # TODO: handle other journey events here
        end
      end

      # save the journey if it has changed
      if journey.changed? && journey.valid?
        journey.save!
        true
      else
        false
      end
    end

  private

    def events
      journey.events.default_order
    end
  end
end
