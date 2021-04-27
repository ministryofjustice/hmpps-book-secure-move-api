module Metrics
  module PersonEscortRecords
    PERSON_ESCORT_RECORDS = 'person escort records'.freeze
    PERSON_ESCORT_RECORDS_DATABASE = 'person_escort_records'.freeze

    def database
      if supplier.present?
        "#{PERSON_ESCORT_RECORDS_DATABASE}_#{supplier.key}"
      else
        PERSON_ESCORT_RECORDS_DATABASE
      end
    end

    def person_escort_records_with_moves
      # NB: this excludes a handful of historic PERs without moves
      if supplier.present?
        PersonEscortRecord.joins(:move).where(moves: { supplier: supplier })
      else
        PersonEscortRecord.joins(:move)
      end
    end
  end
end
