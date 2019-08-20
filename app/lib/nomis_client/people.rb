# frozen_string_literal: true

require 'nomis/faker'

module NomisClient
  class People
    class << self
      def get(nomis_offender_number:)
        return get_test_mode(nomis_offender_number: nomis_offender_number) if NomisClient::Base.test_mode?

        NomisClient::Base.get(
          "/prisoners/#{nomis_offender_number}",
          params: {},
          headers: { 'Page-Limit' => '1000' }
        ).parsed
      end

      def get_test_mode(nomis_offender_number:)
        file_name = "#{NomisClient::Base::FIXTURE_DIRECTORY}/people-#{nomis_offender_number}.json.erb"
        JSON.parse(ERB.new(File.read(file_name)).result)
      end
    end
  end
end
