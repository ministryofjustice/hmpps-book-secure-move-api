# frozen_string_literal: true

module Api
  class AllocationEventsController < ApiController
    include Eventable

    def cancel
      validate_params!(cancel_params)

      allocation.transaction do
        allocation.cancel(**cancellation_details)
        process_event(allocation.moves, GenericEvent::MoveCancel, cancel_move_params)
      end

      render status: :no_content
    end

  private

    PERMITTED_CANCEL_PARAMS = [
      :type,
      { attributes: %i[timestamp cancellation_reason cancellation_reason_comment] },
    ].freeze

    def validate_params!(event_params)
      AllocationEvents::ParamsValidator.new(event_params).validate!(:cancel)
    end

    def cancel_params
      @cancel_params ||= params.require(:data).permit(PERMITTED_CANCEL_PARAMS).to_h
    end

    def cancel_move_params
      cancel_params.deep_merge(attributes: { cancellation_reason: Move::CANCELLATION_REASON_OTHER })
    end

    def cancellation_details
      {
        reason: cancel_params.dig(:attributes, :cancellation_reason),
        comment: cancel_params.dig(:attributes, :cancellation_reason_comment),
      }
    end

    def allocation
      @allocation ||= Allocation.find(params.require(:id))
    end
  end
end
