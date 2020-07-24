# frozen_string_literal: true

module PersonEscortRecords
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :status

    validates :status, inclusion: { in: [PersonEscortRecord::PERSON_ESCORT_RECORD_CONFIRMED, PersonEscortRecord::PERSON_ESCORT_RECORD_PRINTED] }

    def initialize(status)
      @status = status
    end
  end
end
