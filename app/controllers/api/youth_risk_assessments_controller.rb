# frozen_string_literal: true

module Api
  class YouthRiskAssessmentsController < FrameworkAssessmentsController
  private

    def confirm_assessment!(assessment)
      assessment.confirm!(update_assessment_status)
      Notifier.prepare_notifications(topic: assessment, action_name: nil)
    end

    def assessment_class
      YouthRiskAssessment
    end

    def assessment_serializer
      YouthRiskAssessmentSerializer
    end
  end
end
