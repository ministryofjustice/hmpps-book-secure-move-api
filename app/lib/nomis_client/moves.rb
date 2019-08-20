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
        date_offset = offset_from(date: date)
        file_name = "#{NomisClient::Base::FIXTURE_DIRECTORY}/moves-#{date_offset}-#{nomis_agency_id}.json.erb"
        return empty_response unless File.exist?(file_name)

        JSON.parse(ERB.new(File.read(file_name)).result)
      end

      def offset_from(date:)
        (date.in_time_zone.midnight - Time.zone.now.midnight).to_i / 1.days
      end

      def empty_response
        {
          courtEvents: [],
          transferEvents: [],
          releaseEvents: [],
          movements: []
        }
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
    end
  end
end
