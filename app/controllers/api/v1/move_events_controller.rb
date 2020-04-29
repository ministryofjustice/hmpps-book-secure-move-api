# frozen_string_literal: true

module Api
  module V1
    class MoveEventsController < ApiController

      PERMITTED_EVENT_PARAMS = [
        :type,
        attributes: %i[],
        relationships: {},
      ].freeze

      def create
        # NB: this is a *temporary implementation* to immediately address the needs of P4-1355 and allow the frontend to
        # update the destination of a move. They will do this by POSTing a redirect event to this endpoint. For now, we
        # will simply update the move's to_location. In future (P4-1180) we will have an immutable event log.

        puts "TESTING"
        puts "PARAMS: #{params.inspect}"
        puts "EVENT_PARAMS: #{event_params.inspect}"

      end

    private

      def event_params
        params.require(:data).permit(PERMITTED_EVENT_PARAMS).to_h
      end

      def find_move
        Move
          .accessible_by(current_ability)
          .find_by(id: params.dig(:move_id))
      end

    end
  end
end
