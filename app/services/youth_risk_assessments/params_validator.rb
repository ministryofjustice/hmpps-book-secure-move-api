# frozen_string_literal: true

module YouthRiskAssessments
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :status

    validates :status, inclusion: { in: [YouthRiskAssessment::YOUTH_ASSESSMENT_CONFIRMED] }

    def initialize(status)
      @status = status
    end
  end
end
