# frozen_string_literal: true

module Api
  class JourneyEventsController < ApiController
    include Eventable
    include Idempotentable

    before_action :validate_idempotency_key
    around_action :idempotent_action

    COMMON_PARAMS = [:type, { attributes: %i[timestamp notes] }].freeze
    LOCKOUT_PARAMS = [:type, { attributes: %i[timestamp notes], relationships: { from_location: {} } }].freeze
    LODGING_PARAMS = [:type, { attributes: %i[timestamp notes], relationships: { to_location: {} } }].freeze

    def cancel
      JourneyEvents::ParamsValidator.new(common_params).validate!
      process_event(journey, GenericEvent::JourneyCancel, common_params)
      render status: :no_content
    end

    def complete
      JourneyEvents::ParamsValidator.new(common_params).validate!
      process_event(journey, GenericEvent::JourneyComplete, common_params)
      render status: :no_content
    end

    def lockouts
      JourneyEvents::ParamsValidator.new(lockout_params).validate!
      process_event(journey, GenericEvent::JourneyLockout, lockout_params)
      render status: :no_content
    end

    def lodgings
      JourneyEvents::ParamsValidator.new(lodging_params).validate!
      process_event(journey, GenericEvent::JourneyLodging, lodging_params)
      render status: :no_content
    end

    def reject
      JourneyEvents::ParamsValidator.new(common_params).validate!
      process_event(journey, GenericEvent::JourneyReject, common_params)
      render status: :no_content
    end

    def start
      JourneyEvents::ParamsValidator.new(common_params).validate!
      process_event(journey, GenericEvent::JourneyStart, common_params)
      render status: :no_content
    end

    def uncancel
      JourneyEvents::ParamsValidator.new(common_params).validate!
      process_event(journey, GenericEvent::JourneyUncancel, common_params)
      render status: :no_content
    end

    def uncomplete
      JourneyEvents::ParamsValidator.new(common_params).validate!
      process_event(journey, GenericEvent::JourneyUncomplete, common_params)
      render status: :no_content
    end

  private

    def lockout_params
      @lockout_params ||= params.require(:data).permit(LOCKOUT_PARAMS).to_h
    end

    def lodging_params
      @lodging_params ||= params.require(:data).permit(LODGING_PARAMS).to_h
    end

    def common_params
      @common_params ||= params.require(:data).permit(COMMON_PARAMS).to_h
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
