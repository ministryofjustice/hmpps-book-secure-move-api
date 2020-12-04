# frozen_string_literal: true

module Api
  module Reference
    class AssessmentQuestionsController < ApiController
      def index
        types = AssessmentQuestions::Finder.new(filter_params).call
        render_json types, serializer: AssessmentQuestionSerializer
      end

    private

      PERMITTED_FILTER_PARAMS = %i[category].freeze

      def filter_params
        params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
      end
    end
  end
end
