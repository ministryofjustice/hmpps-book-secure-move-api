# frozen_string_literal: true

module Api
  class YouthRiskAssessmentsController < FrameworkAssessmentsController
  private

    def assessment_class
      YouthRiskAssessment
    end

    def assessment_serializer
      YouthRiskAssessmentSerializer
    end
  end
end
