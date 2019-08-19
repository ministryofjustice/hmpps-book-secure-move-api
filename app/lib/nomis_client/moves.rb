# frozen_string_literal: true

module NomisClient
  class Moves < NomisClient::Base
    class << self
      def get(nomis_agency_ids:, date:)
        return get_test_mode(nomis_agency_id: nomis_agency_ids, date: date) if NomisClient::Base.test_mode?

        NomisClient::Base.get(
          '/movements/transfers',
          params: params_for(nomis_agency_ids, date),
          headers: { 'Page-Limit' => '1000' }
        ).parsed
      end

      def get_test_mode(nomis_agency_id:, date:)
        file_name = "#{NomisClient::Base::FIXTURE_DIRECTORY}/moves-#{date}-#{nomis_agency_id}.json.erb"
        JSON.parse(ERB.new(File.read(file_name)).result)
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

      def anonymise(offender_number, day_offset, move_response)
        start_date_time = move_response['startTime'].present? ? Time.parse(move_response['startTime']) : nil
        start_time = start_date_time&.strftime('%H:%M:%S') || '00:00:00'

        move_response.merge(
          offenderNo: offender_number,
          judgeName: nil,
          commentText: nil,
          createDateTime: "<%= (Time.now + #{day_offset}.days)&.iso8601 %>",
          eventDate: "<%= (Time.now + #{day_offset}.days)&.strftime('%Y-%m-%d') %>",
          startTime: "<%= (Time.now + #{day_offset}.days)&.strftime('%Y-%m-%d') + 'T' + '#{start_time}' %>"
        ).with_indifferent_access
      end
    end
  end
end
