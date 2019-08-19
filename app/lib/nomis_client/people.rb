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

      def prisons
        Location.where(location_type: 'prison').all
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def anonymise(_person_response)
        latest_location = prisons.sample
        {
          offenderNo: Nomis::Faker.nomis_offender_number,
          firstName: Faker::Name.first_name,
          middleNames: Faker::Name.first_name,
          lastName: Faker::Name.last_name,
          dateOfBirth: Faker::Date.between(80.years.ago, 20.years.ago),
          gender: %w[Male Female].sample,
          sexCode: %w[M F].sample,
          nationalities: %w[British Irish Dutch American Japanese].sample,
          currentlyInPrison: %w[Y N].sample,
          latestBookingId: 1_234_567,
          latestLocationId: latest_location.nomis_agency_id,
          latestLocation: latest_location.title,
          internalLocation: 'ABC-D-1-23',
          pncNumber: Nomis::Faker.pnc_number,
          croNumber: Nomis::Faker.cro_number,
          ethnicity: Nomis::Faker.ethnicity,
          birthCountry: Nomis::Faker.birth_country,
          religion: Nomis::Faker.religion,
          convictedStatus: Nomis::Faker.conviction_status,
          imprisonmentStatus: Nomis::Faker.imprisonment_status,
          receptionDate: nil,
          maritalStatus: Nomis::Faker.marital_status
        }.with_indifferent_access
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
