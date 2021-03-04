# frozen_string_literal: true

module Api
  class PersonEscortRecordsController < FrameworkAssessmentsController
    include Eventable

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

      create_event_and_notification!
    end

    def assessment_class
      PersonEscortRecord
    end

    def assessment_serializer
      PersonEscortRecordSerializer
    end

    def create_event_and_notification!
      create_automatic_event!(eventable: assessment, event_class: GenericEvent::PerHandover, occurred_at: assessment.handover_occurred_at, details: assessment.handover_details)
      Notifier.prepare_notifications(topic: assessment, action_name: 'handover_person_escort_record')
    end
  end
end
