# frozen_string_literal: true

class NomisClient
  class Moves
    class << self
      def get(nomis_agency_ids:, date:)
        NomisClient.get(
          '/movements/transfers',
          params: params_for(nomis_agency_ids, date),
          headers: { 'Page-Limit' => '1000' }
        ).parsed
      end

      def params_for(nomis_agency_ids, date)
        {
          agencyId: nomis_agency_ids,
          fromDateTime: date.beginning_of_day.iso8601.split('+').first,
          toDateTime: (date + 1.day).beginning_of_day.iso8601.split('+').first,
          courtEvents: true,
          releaseEvents: true,
          transferEvents: true,
          movements: true
        }
      end

      def anonymise(offender_number, move_response)
        move_response.merge(
          offenderNo: offender_number,
          judgeName: nil,
          commentText: nil
        ).with_indifferent_access
      end
    end
  end
end
