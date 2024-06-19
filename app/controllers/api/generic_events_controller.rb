module Api
  class GenericEventsController < ApiController
    PERMITTED_EVENT_PARAMS = [
      :type,
      { attributes: [
          :event_type,
          :occurred_at,
          :recorded_at,
          :notes,
          { details: {} },
        ],
        relationships: {} },
    ].freeze

    def create
      GenericEvents::CommonParamsValidator.new(event_params, event_relationships).validate!
      event = event_type.constantize.create!(event_attributes)
      was_cross_deck = cross_deck_move?(event.eventable)

      run_event_logs

      unless doorkeeper_application_owner.is_a?(Supplier)
        Notifier.prepare_notifications(topic: event, action_name: 'create_event')
      end

      if !was_cross_deck && cross_deck_move?(event.eventable)
        Notifier.prepare_notifications(topic: event.eventable, action_name: 'cross_supplier_add')
      end

      if was_cross_deck && !cross_deck_move?(event.eventable)
        Notifier.prepare_notifications(topic: event.eventable, action_name: 'cross_supplier_remove')
      end

      render_event(event, :created)
    end

    def show
      render_event(event, :ok)
    end

  private

    def cross_deck_move?(eventable)
      eventable.reload.is_a?(Move) && eventable.cross_deck?
    end

    def render_event(event, status)
      render_json event, serializer: event.class.serializer, status:
    end

    def event
      @event ||= GenericEvent
                  .includes(active_record_relationships)
                  .find(params[:id])
    end

    def event_attributes
      {}.tap do |attributes|
        attributes.merge!(event_params.fetch(:attributes, {}))

        attributes.delete('event_type')

        attributes.merge!('supplier' => doorkeeper_application_owner) if doorkeeper_application_owner
        attributes.merge!('eventable' => eventable) if eventable_params
        attributes.merge!('created_by' => created_by) if created_by
        attributes['details'] = attributes['details']&.slice(*event_type.constantize.details_attributes) || {}

        attributes['details'].merge!(event_specific_relationships) if event_specific_relationships.any?
      end
    end

    def event_params
      params.require(:data).permit(PERMITTED_EVENT_PARAMS).to_h
    end

    def event_relationships
      @event_relationships ||= params.require(:data)[:relationships].to_unsafe_hash
    end

    def eventable_params
      @eventable_params ||= event_relationships[:eventable]
    end

    def eventable
      type = eventable_params.dig('data', 'type')
      id = eventable_params.dig('data', 'id')

      type.singularize.camelize.constantize.find(id)
    end

    def event_type
      @event_type ||= "GenericEvent::#{event_remap(event_params.dig('attributes', 'event_type'))}"
    end

    def event_specific_relationships
      GenericEvents::EventSpecificRelationshipsMapper.new(event_relationships).call
    end

    def run_event_logs
      GenericEvents::Runner.new(eventable).call
    end

    def event_remap(original_event)
      {
        'MoveNotifyPremisesOfEta' => 'MoveNotifyPremisesOfDropOffEta',
      }[original_event] || original_event
    end
  end
end
