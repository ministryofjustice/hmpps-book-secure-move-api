# frozen_string_literal: true

module NomisClient
  class Moves
    class << self
      def get(nomis_agency_ids:, date:)
        NomisClient::Base.get(
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
        start_date_time = move_response['startTime'].present? ? Time.parse(move_response['startTime']) : nil
        start_time = start_date_time&.strftime('%H:%M:%S') || '00:00:00'

        move_response.merge(
          offenderNo: offender_number,
          judgeName: nil,
          commentText: nil,
          createDateTime: "<%= (Time.now + #{day_offset}.days)&.iso8601 %>",
          eventDate: "<%= (Time.now + #{day_offset}.days)&.to_date&.iso8601 %>",
          startTime: "<%= (Time.now + #{day_offset}.days)&.iso8601 + 'T' + '#{start_time}' %>",
        ).with_indifferent_access
      end
      # rubocop:enable Lint/UselessAssignment
    end
  end
end
