module Journeys
  module Eventable
    extend ActiveSupport::Concern

    def supplier_id
      # NB: not all events will have a supplier_id so this could well be nil
      @supplier_id ||= current_user.owner&.id
    end

    def process_event(journeys, event_name, event_params)
      [journeys].flatten.each do |journey|
        event = create_event(journey, event_name, event_params)
        create_generic_event(event)
        run_event_logs(journey)
      end
    end

    def create_event(journey, event_name, event_params)
      journey.events.create!(
        event_name: event_name,
        client_timestamp: Time.zone.parse(event_params.dig(:attributes, :timestamp)),
        details: {
          event_params: event_params,
          supplier_id: supplier_id,
        },
      )
    end

    def create_generic_event(event)
      generic_event = GenericEvent.from_event(event)
      generic_event.save!
      event.update!(generic_event_id: generic_event.id)
    end

    def run_event_logs(journey)
      EventLog::JourneyRunner.new(journey).call
    end
  end
end
