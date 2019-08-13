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

      # rubocop:disable Lint/UselessAssignment
      def anonymise(offender_number, day_offset, move_response)
        now = Time.now + day_offset.days
        start_time = move_response['startTime'].present? ? Time.parse(move_response['startTime']).change(year: now.year, month: now.month, day: now.day) : nil

        move_response.merge(
          offenderNo: offender_number,
          judgeName: nil,
          commentText: nil,
          createDateTime: '<%= now&.iso8601 %>',
          eventDate: '<%= now&.to_date&.iso8601 %>',
          startTime: '<%= start_time&.to_date&.iso8601 %>'
        ).with_indifferent_access
      end
      # rubocop:enable Lint/UselessAssignment
    end
  end
end
