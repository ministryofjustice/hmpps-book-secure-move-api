module Api
  class EventsController < ApplicationController
    EVENT_ATTRIBUTES = %i[
      client_timestamp
      notes
      details
    ].freeze

    PERMITTED_EVENT_PARAMS = [:type, attributes: EVENT_ATTRIBUTES, relationships: {}].freeze

    def create
      event = Event.create!(event_attributes)

      render json: event, status: status, serializer: ::EventSerializer
    end

  private

    def event_attributes
      {}.tap do |attributes|
        attributes.merge!(event_params.fetch(:attributes, {}))
        attributes.merge!(eventable: eventable) if eventable_params
      end
    end

    def event_params
      params.require(:data).permit(PERMITTED_EVENT_PARAMS).to_h
    end

    def eventable_params
      @eventable_params ||= params.require(:data).dig(:relationships, :eventable)
    end

    def eventable
      type = eventable_params['type']
      id = eventable_params['id']

      type.singularize.capitalize.constantize.find(id)
    end
  end
end
