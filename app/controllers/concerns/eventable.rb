module Eventable
  extend ActiveSupport::Concern

  def api_supplier_id
    # NB: not all events will have a supplier_id so this could well be nil
    doorkeeper_application_owner&.id
  end

  def process_event(eventables, event_sti_class, event_params)
    [eventables].flatten.each do |eventable|
      create_generic_event!(eventable, event_sti_class, event_params)
      run_event_logs(eventable)
    end
  end

  def create_generic_event!(eventable, event_sti_class, event_params)
    attributes = {}
    assign_common_attributes!(attributes, eventable, event_params)
    assign_specific_attributes!(attributes, event_params, event_sti_class)

    event_sti_class.create!(attributes)
  end

  def create_automatic_event!(eventable:, event_class:, occurred_at: nil, supplier_id: nil, details: {})
    return unless eventable && event_class

    now = Time.zone.now

    event_class.create!(
      eventable: eventable,
      occurred_at: occurred_at || now,
      recorded_at: now,
      notes: 'Automatically generated event',
      details: details,
      supplier_id: supplier_id || api_supplier_id,
      created_by: created_by,
    )
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
    attributes[:supplier_id] = api_supplier_id
    attributes[:created_by]  = created_by
  end

  def assign_specific_attributes!(attributes, event_params, event_sti_class)
    attributes[:details] = {}
    attributes[:details].merge!(::GenericEvents::EventSpecificRelationshipsMapper.new(event_params[:relationships]).call)
    attributes[:details].merge!(event_params[:attributes].slice(*event_sti_class.details_attributes))
  end
end
