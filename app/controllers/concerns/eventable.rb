module Eventable
  extend ActiveSupport::Concern

  def supplier_id
    # NB: not all events will have a supplier_id so this could well be nil
    @supplier_id ||= current_user.owner&.id
  end

  def process_event(eventables, event_name, event_params)
    [eventables].flatten.each do |eventable|
      event = create_event(eventable, event_name, event_params)
      create_generic_event(event)
      run_event_logs(eventable)
    end
  end

  def create_event(eventable, event_name, event_params)
    eventable.events.create!(
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

  def run_event_logs(eventable)
    GenericEvents::Runner.new(eventable).call
  end
end
