module Eventable
  extend ActiveSupport::Concern

  def supplier_id
    # NB: not all events will have a supplier_id so this could well be nil
    @supplier_id ||= current_user.owner&.id
  end

  def process_event(eventables, event_name, event_params)
    [eventables].flatten.each do |eventable|
      create_generic_event(eventable, event_name, event_params)
      run_event_logs(eventable)
    end
  end

  def create_generic_event(eventable, event_name, event_params)
    eventable_type = eventable.class.to_s
    type = "GenericEvent::#{eventable_type}#{event_name.camelize}".constantize

    attributes = {}
    assign_common_attributes!(attributes, eventable, event_params)
    assign_specific_attributes!(attributes, event_params, type)

    type.create!(attributes)
  end

  def run_event_logs(eventable)
    GenericEvents::Runner.new(eventable).call
  end

private

  def assign_common_attributes!(attributes, eventable, event_params)
    timestamp = Time.zone.parse(event_params.dig(:attributes, :timestamp))

    attributes[:eventable]   = eventable
    attributes[:occurred_at] = timestamp
    attributes[:recorded_at] = timestamp
    attributes[:notes]       = event_params.dig(:attributes, :notes)
    attributes[:supplier_id] = supplier_id
  end

  def assign_specific_attributes!(attributes, event_params, type)
    attributes[:details] = {}
    attributes[:details].merge!(::GenericEvents::EventSpecificRelationshipsMapper.new(event_params[:relationships]).call)
    attributes[:details].merge!(event_params[:attributes].slice(*type::DETAILS_ATTRIBUTES))
  end
end
