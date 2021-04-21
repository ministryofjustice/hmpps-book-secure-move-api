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
        PersonEscortRecord.joins(:move).where(moves: { supplier: supplier })
      else
        PersonEscortRecord.all
      end
    end
  end
end
