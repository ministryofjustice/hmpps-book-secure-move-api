# frozen_string_literal: true

module AssessmentQuestions
  class Finder
    attr_accessor :filter_params

    def initialize(filter_params)
      self.filter_params = filter_params
    end

    def call
      AssessmentQuestion.where(filter_params.slice(:category))
    end
  end
end
