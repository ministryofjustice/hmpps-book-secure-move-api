module Api
  class EventsController < ApiController
    PERMITTED_EVENT_PARAMS = [
      :type,
      attributes: [
        :event_type,
        :client_timestamp,
        :notes,
        details: {},
      ],
      relationships: {},
    ].freeze

    def create
      Events::CommonParamsValidator.new(event_params).validate!
      event = Event.create(event_attributes)

      render json: event, status: :created, serializer: ::EventSerializer
    end

  private

    def event_attributes
      {}.tap do |attributes|
        attributes.merge!(event_params.fetch(:attributes, {}))

        # NB: json:api doesn't like the rails convention to name the STI column as type. We require 'event_type' in the request but the column is actually type
        attributes.delete('event_type')

        attributes.merge!('type' => event_type)
        attributes.merge!('event_name' => Event::NA)
        attributes.merge!('eventable' => eventable) if eventable_params
      end
    end

    def event_params
      params.require(:data).permit(PERMITTED_EVENT_PARAMS).to_h
    end

    def eventable_params
      @eventable_params ||= params.require(:data).dig(:relationships, :eventable)
    end

    def eventable
      type = eventable_params.dig('data', 'type')
      id = eventable_params.dig('data', 'id')

      type.singularize.capitalize.constantize.find(id)
    end

    def event_type
      @event_type ||= 'Event::' + event_params.dig('attributes', 'event_type')
    end
  end
end
