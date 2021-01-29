# frozen_string_literal: true

module Api
  class PersonEscortRecordsController < FrameworkAssessmentsController
    after_action :create_confirmation_event, only: :update # rubocop:disable LexicallyScopedActionFilter

    UPDATE_PER_PERMITTED_PARAMS = [
      :type,
      attributes: [:status, handover_details: {}],
    ].freeze

  private

    def update_assessment_params
      params.require(:data).permit(UPDATE_PER_PERMITTED_PARAMS)
    end

    def confirm_assessment!(assessment)
      handover_details = update_assessment_params.to_h.dig(:attributes, :handover_details)
      assessment.confirm!(update_assessment_status, handover_details)
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
