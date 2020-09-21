module EventLog
  class JourneyExecutor
    attr_reader :journey

    def initialize(journey)
      @journey = journey
    end

    def call
      # iterate over all events in the log and apply changes to the journey
      journey.generic_events.applied_order.each(&:trigger)

      if journey.changed? && journey.valid?
        journey.save!
      end
    end
  end
end

