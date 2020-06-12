# frozen_string_literal: true

module Api
  module V1
    class JourneyEventsController < ApiController
      include Journeys::Eventable

      STANDARD_PARAMS = [:type, attributes: %i[timestamp notes]].freeze
      LOCKOUT_PARAMS = [:type, attributes: %i[timestamp notes], relationships: { from_location: {} }].freeze
      LODGING_PARAMS = [:type, attributes: %i[timestamp notes], relationships: { to_location: {} }].freeze

      def cancel
        validate_params!(standard_params)
        process_event(journey, Event::CANCEL, standard_params)
        render status: :no_content
      end

      def complete
        validate_params!(standard_params)
        process_event(journey, Event::COMPLETE, standard_params)
        render status: :no_content
      end

      def lockouts
        validate_params!(lockout_params, require_from_location: true)
        process_event(journey, Event::LOCKOUT, lockout_params)
        render status: :no_content
      end

      def lodgings
        validate_params!(lockout_params, require_to_location: true)
        process_event(journey, Event::LODGING, lodging_params)
        render status: :no_content
      end

      def reject
        validate_params!(standard_params)
        process_event(journey, Event::REJECT, standard_params)
        render status: :no_content
      end

      def start
        validate_params!(standard_params)
        process_event(journey, Event::START, standard_params)
        render status: :no_content
      end

      def uncancel
        validate_params!(standard_params)
        process_event(journey, Event::UNCANCEL, standard_params)
        render status: :no_content
      end

      def uncomplete
        validate_params!(standard_params)
        process_event(journey, Event::UNCOMPLETE, standard_params)
        render status: :no_content
      end

    private

      def validate_params!(event_params, require_from_location: false, require_to_location: false)
        JourneyEvents::ParamsValidator.new(event_params).validate!
        if require_from_location
          Location.find(params.require(:data).require(:relationships).require(:from_location).require(:data).require(:id))
        end
        if require_to_location
          Location.find(params.require(:data).require(:relationships).require(:to_location).require(:data).require(:id))
        end
      end

      def lockout_params
        @lockout_params ||= params.require(:data).permit(LOCKOUT_PARAMS).to_h
      end

      def lodging_params
        @lodging_params ||= params.require(:data).permit(LODGING_PARAMS).to_h
      end

      def standard_params
        @standard_params ||= params.require(:data).permit(STANDARD_PARAMS).to_h
      end

      def journey
        @journey ||= find_journey
      end

      def find_journey
        Move
          .accessible_by(current_ability)
          .find(params.require(:move_id))
          .journeys
          .find(params.require(:id))
          .tap do |journey|
          raise CanCan::AccessDenied.new('Not authorized', :manage, Journey) unless current_ability.can?(:manage, journey)
        end
      end
    end
  end
end
