# frozen_string_literal: true

module Api
  class PersonEscortRecordsController < FrameworkAssessmentsController
  private

    def assessment_class
      PersonEscortRecord
    end

    def assessment_serializer
      PersonEscortRecordSerializer
    end
  end
end
