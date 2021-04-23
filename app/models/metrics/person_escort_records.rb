module Metrics
  module PersonEscortRecords
    PERSON_ESCORT_RECORDS_DATABASE = 'pers'.freeze

    def database
      if supplier.present?
        "#{PERSON_ESCORT_RECORDS_DATABASE}_#{supplier.key}"
      else
        PERSON_ESCORT_RECORDS_DATABASE
      end
    end

    def person_escort_records
      if supplier.present?
        person_escort_records_with_moves.where(moves: { supplier: supplier })
      else
        PersonEscortRecord.all
      end
    end

    def person_escort_records_with_moves
      # NB: this excludes a handful of historic PERs without moves
      PersonEscortRecord.joins(:move)
    end
  end
end
