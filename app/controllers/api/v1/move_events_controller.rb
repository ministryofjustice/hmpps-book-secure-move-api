# frozen_string_literal: true

module Api
  module V1
    class MoveEventsController < ApiController
      before_action :validate_params

      PERMITTED_EVENT_PARAMS = [
        :type,
        attributes: %i[timestamp event_name notes],
        relationships: { to_location: {} },
      ].freeze

      def complete
        create_event('complete')
        run_event_logs
        render status: :no_content
      end

      def redirects
        create_event('redirect')
        run_event_logs
        render status: :no_content
      end

      def events
        # TODO: this method should be deleted, but kept here until the front end is updated
        if  event_name == 'redirect'
          event = create_event(event_name)
          run_event_logs
          render status: :created,
                 json: {
                   data: {
                     id: event.id,
                     type: 'events',
                     attributes: {
                       event_name: event.event_name,
                       timestamp: event.client_timestamp,
                       notes: event.notes,
                     },
                     relationships: {
                       to_location: {
                         data: {
                           type: 'locations',
                           id: event.to_location.id,
                         },
                       },
                     },
                   },
                 }
        else
          render status: :bad_request,
                 json: {
                   errors: [{ title: 'invalid event_name', detail: "#{event_name} is not supported" }],
                 }
        end
      end

    private

      def validate_params
        MoveEvents::ParamsValidator.new(event_params).validate!
      end

      def event_params
        @event_params ||= params.require(:data).permit(PERMITTED_EVENT_PARAMS).to_h
      end

      def event_name
        @event_name ||= event_params.dig(:attributes, :event_name)
      end

      def timestamp
        @timestamp ||= Time.zone.parse(event_params.dig(:attributes, :timestamp))
      end

      def supplier_id
        # NB: not all events will have a supplier_id so this could well be nil
        current_user.owner&.id
      end

      def move
        @move ||= Move.accessible_by(current_ability).find(params.require(:id))
      end

      def create_event(event_name)
        move.events.create!(
          event_name: event_name,
          client_timestamp: timestamp,
          details: {
            event_params: event_params,
            supplier_id: supplier_id,
          },
        )
      end

      def run_event_logs
        EventLog::MoveRunner.new(move).call
      end
    end
  end
end
