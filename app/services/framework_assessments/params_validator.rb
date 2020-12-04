# frozen_string_literal: true

module FrameworkAssessments
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :status

    validates :status, inclusion: { in: [FrameworkAssessmentable::ASSESSMENT_CONFIRMED] }

    def initialize(status)
      @status = status
    end
  end
end
