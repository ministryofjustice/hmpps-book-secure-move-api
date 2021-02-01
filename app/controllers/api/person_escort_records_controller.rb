# frozen_string_literal: true

module Api
  class PersonEscortRecordsController < FrameworkAssessmentsController
    after_action :create_confirmation_event, only: :update # rubocop:disable LexicallyScopedActionFilter

    UPDATE_PER_PERMITTED_PARAMS = [
      :type,
      attributes: [:status, :handover_occurred_at, handover_details: {}],
    ].freeze

  private

    def update_assessment_params
      params.require(:data).permit(UPDATE_PER_PERMITTED_PARAMS)
    end

    def confirm_assessment!(assessment)
      handover_details = update_assessment_params.to_h.dig(:attributes, :handover_details)
      handover_occurred_at = update_assessment_params.to_h.dig(:attributes, :handover_occurred_at)
      assessment.confirm!(update_assessment_status, handover_details, handover_occurred_at)
    end

    def assessment_class
      PersonEscortRecord
    end

    def assessment_serializer
      PersonEscortRecordSerializer
    end

    def create_confirmation_event
      now = Time.zone.now.iso8601

      event_attributes = {
        eventable: assessment,
        occurred_at: now,
        recorded_at: now,
        notes: 'Automatically generated event',
        details: {
          confirmed_at: assessment.confirmed_at.iso8601,
        },
        created_by: created_by,
      }

      GenericEvent::PerConfirmation.create!(event_attributes)
    end
  end
end
