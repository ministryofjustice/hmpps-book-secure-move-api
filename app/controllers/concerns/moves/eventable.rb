module Moves
  module Eventable
    extend ActiveSupport::Concern

    def supplier_id
      # NB: not all events will have a supplier_id so this could well be nil
      @supplier_id ||= current_user.owner&.id
    end

    def process_event(moves, event_name, event_params)
      [moves].flatten.each do |move|
        event = create_event(move, event_name, event_params)
        create_generic_event(event)
        run_event_logs(move)
      end
    end

    def create_event(move, event_name, event_params)
      move.move_events.create!(
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
      generic_event
    end

    def run_event_logs(move)
      EventLog::MoveRunner.new(move).call
    end
  end
end
