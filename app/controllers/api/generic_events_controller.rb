module Api
  class GenericEventsController < ApiController
    PERMITTED_EVENT_PARAMS = [
      :type,
      attributes: [
        :event_type,
        :occurred_at,
        :recorded_at,
        :notes,
        details: {},
      ],
      relationships: {},
    ].freeze

    def create
      GenericEvents::CommonParamsValidator.new(event_params, event_relationships).validate!
      event = event_type.constantize.create!(event_attributes)

      render json: event, status: :created, serializer: ::GenericEventSerializer
    end

  private

    def event_attributes
      {}.tap do |attributes|
        attributes.merge!(event_params.fetch(:attributes, {}))

        attributes.delete('event_type')

        attributes.merge!('supplier' => doorkeeper_application_owner) if doorkeeper_application_owner
        attributes.merge!('eventable' => eventable) if eventable_params

        attributes['details'].merge!(event_specific_relationships) if event_specific_relationships.any?
      end
    end

    def event_params
      params.require(:data).permit(PERMITTED_EVENT_PARAMS).to_h
    end

    def event_relationships
      @event_relationships ||= params.require(:data)[:relationships]
    end

    def eventable_params
      @eventable_params ||= event_relationships[:eventable]
    end

    def eventable
      type = eventable_params.dig('data', 'type')
      id = eventable_params.dig('data', 'id')

      type.singularize.capitalize.constantize.find(id)
    end

    def event_type
      @event_type ||= 'GenericEvent::' + event_params.dig('attributes', 'event_type')
    end

    def created_by
      current_user&.owner&.name || 'unknown'
    end

    def event_specific_relationships
      event_specific_relationships = event_relationships.to_unsafe_hash.except('eventable')
      event_specific_relationships.each_with_object({}) do |(relationship, relationship_attributes), acc|
        key = "#{relationship}_id"
        id = relationship_attributes.dig(:data, :id)

        acc[key] = id
      end
    end
  end
end
