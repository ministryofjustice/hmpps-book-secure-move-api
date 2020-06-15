# frozen_string_literal: true

module Api
  module V1
    class MoveEventsController < ApiController
      include Moves::Eventable

      CANCEL_PARAMS = [:type, attributes: %i[timestamp cancellation_reason cancellation_reason_comment notes]].freeze
      COMPLETE_PARAMS = [:type, attributes: %i[timestamp notes]].freeze
      LOCKOUT_PARAMS = [:type, attributes: %i[timestamp notes], relationships: { from_location: {} }].freeze
      REDIRECT_PARAMS = [:type, attributes: %i[timestamp notes], relationships: { to_location: {} }].freeze
      APPROVE_PARAMS = [:type, attributes: %i[timestamp date]].freeze
      REJECT_PARAMS = [:type, attributes: %i[timestamp rejection_reason cancellation_reason_comment]].freeze

      def cancel
        validate_params!(cancel_params)
        process_event(move, Event::CANCEL, cancel_params)
        render status: :no_content
      end

      def complete
        validate_params!(complete_params)
        process_event(move, Event::COMPLETE, complete_params)
        render status: :no_content
      end

      def lockouts
        validate_params!(lockout_params, require_from_location: true)
        process_event(move, Event::LOCKOUT, lockout_params)
        render status: :no_content
      end

      def redirects
        validate_params!(redirect_params, require_to_location: true)
        process_event(move, Event::REDIRECT, redirect_params)
        render status: :no_content
      end

      def approve
        validate_params!(approve_params)
        process_event(move, Event::APPROVE, approve_params)
        render status: :no_content
      end

      def reject
        validate_params!(reject_params)
        process_event(move, Event::REJECT, reject_params)
        render status: :no_content
      end

    private

      def validate_params!(event_params, require_from_location: false, require_to_location: false)
        MoveEvents::ParamsValidator.new(event_params).validate!
        if require_from_location
          Location.find(params.require(:data).require(:relationships).require(:from_location).require(:data).require(:id))
        end
        if require_to_location
          Location.find(params.require(:data).require(:relationships).require(:to_location).require(:data).require(:id))
        end
      end

      def cancel_params
        @cancel_params ||= params.require(:data).permit(CANCEL_PARAMS).to_h
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

      def approve_params
        @approve_params ||= params.require(:data).permit(APPROVE_PARAMS).to_h
      end

      def reject_params
        @reject_params ||= params.require(:data).permit(REJECT_PARAMS).to_h
      end

      def move
        @move ||= Move.accessible_by(current_ability).find(params.require(:id))
      end
    end
  end
end
