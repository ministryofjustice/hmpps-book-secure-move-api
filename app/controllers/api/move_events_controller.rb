# frozen_string_literal: true

module Api
  class MoveEventsController < ApiController
    include Eventable
    include Idempotentable

    before_action :validate_idempotency_key
    around_action :idempotent_action

    APPROVE_PARAMS = [:type, attributes: %i[timestamp date create_in_nomis]].freeze
    CANCEL_PARAMS = [:type, attributes: %i[timestamp cancellation_reason cancellation_reason_comment notes]].freeze
    LOCKOUT_PARAMS = [:type, attributes: %i[timestamp notes], relationships: { from_location: {} }].freeze
    REDIRECT_PARAMS = [:type, attributes: %i[timestamp notes move_type], relationships: { to_location: {} }].freeze
    REJECT_PARAMS = [:type, attributes: %i[timestamp rejection_reason cancellation_reason_comment rebook]].freeze

    COMMON_PARAMS = [:type, attributes: %i[timestamp notes]].freeze # for accept, complete and start move events

    def accept
      MoveEvents::ParamsValidator.new(common_params).validate!
      process_event(move, GenericEvent::MoveAccept, common_params)
      render status: :no_content
    end

    def approve
      MoveEvents::ParamsValidator.new(approve_params).validate!
      process_event(move, GenericEvent::MoveApprove, approve_params)
      render status: :no_content
    end

    def cancel
      MoveEvents::ParamsValidator.new(cancel_params).validate!
      process_event(move, GenericEvent::MoveCancel, cancel_params)
      render status: :no_content
    end

    def complete
      MoveEvents::ParamsValidator.new(common_params).validate!
      process_event(move, GenericEvent::MoveComplete, common_params)
      render status: :no_content
    end

    def lockouts
      MoveEvents::ParamsValidator.new(lockout_params).validate!
      process_event(move, GenericEvent::MoveLockout, lockout_params)
      render status: :no_content
    end

    def redirects
      MoveEvents::ParamsValidator.new(redirect_params).validate!
      process_event(move, GenericEvent::MoveRedirect, redirect_params)
      render status: :no_content
    end

    def reject
      MoveEvents::ParamsValidator.new(reject_params).validate!
      process_event(move, GenericEvent::MoveReject, reject_params)
      render status: :no_content
    end

    def start
      MoveEvents::ParamsValidator.new(common_params).validate!
      process_event(move, GenericEvent::MoveStart, common_params)
      render status: :no_content
    end

  private

    def approve_params
      @approve_params ||= params.require(:data).permit(APPROVE_PARAMS).to_h
    end

    def cancel_params
      @cancel_params ||= params.require(:data).permit(CANCEL_PARAMS).to_h
    end

    def lockout_params
      @lockout_params ||= params.require(:data).permit(LOCKOUT_PARAMS).to_h
    end

    def redirect_params
      @redirect_params ||= params.require(:data).permit(REDIRECT_PARAMS).to_h
    end

    def reject_params
      @reject_params ||= params.require(:data).permit(REJECT_PARAMS).to_h
    end

    def common_params
      @common_params ||= params.require(:data).permit(COMMON_PARAMS).to_h
    end

    def move
      @move ||= Move.accessible_by(current_ability).find(params.require(:id))
    end
  end
end
