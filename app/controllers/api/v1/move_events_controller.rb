# frozen_string_literal: true

module Api
  module V1
    class MoveEventsController < ApiController
      COMPLETE_PARAMS = [:type, attributes: %i[timestamp notes]].freeze
      LOCKOUT_PARAMS = [:type, attributes: %i[timestamp notes], relationships: { from_location: {} }].freeze
      REDIRECT_PARAMS = [:type, attributes: %i[timestamp notes], relationships: { to_location: {} }].freeze
      DEPRECIATED_EVENT_PARAMS = [:type, attributes: %i[timestamp event_name notes], relationships: { to_location: {} }].freeze

      def complete
        validate_params!(complete_params)
        create_event('complete', complete_params)
        run_event_logs
        render status: :no_content
      end

      def lockouts
        validate_params!(lockout_params, require_from_location: true)
        create_event('lockout', lockout_params)
        run_event_logs
        render status: :no_content
      end

      def redirects
        validate_params!(redirect_params, require_to_location: true)
        create_event('redirect', redirect_params)
        run_event_logs
        render status: :no_content
      end

      def events
        # TODO: this method should be deleted, but kept here until the front end is updated
        validate_params!(depreciated_event_params, require_to_location: true)
        if  depreciated_event_params.dig(:attributes, :event_name) == 'redirect'
          event = create_event('redirect', depreciated_event_params)
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
                   errors: [{ title: 'invalid event_name', detail: 'event_name is not supported' }],
                 }
        end
      end

    private

      def validate_params!(event_params, require_from_location: false, require_to_location: false)
        MoveEvents::ParamsValidator.new(event_params).validate!
        params.require(:data).require(:relationships).require(:from_location).require(:data).require(:id) if require_from_location
        params.require(:data).require(:relationships).require(:to_location).require(:data).require(:id) if require_to_location
      end

      def complete_params
        @complete_params ||= params.require(:data).permit(COMPLETE_PARAMS).to_h
      end

      def lockout_params
        @lockout_params ||= params.require(:data).permit(LOCKOUT_PARAMS).to_h
      end

      def redirect_params
        @redirect_params ||= params.require(:data).permit(REDIRECT_PARAMS).to_h
      end

      def depreciated_event_params
        # TODO: deleteme once FE updated
        @depreciated_event_params ||= params.require(:data).permit(DEPRECIATED_EVENT_PARAMS).to_h
      end

      def supplier_id
        # NB: not all events will have a supplier_id so this could well be nil
        current_user.owner&.id
      end

      def move
        @move ||= Move.accessible_by(current_ability).find(params.require(:id))
      end

      def create_event(event_name, event_params)
        move.move_events.create!(
          event_name: event_name,
          client_timestamp: Time.zone.parse(event_params.dig(:attributes, :timestamp)),
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
