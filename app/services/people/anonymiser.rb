# frozen_string_literal: true

require 'nomis/faker'

module People
  class Anonymiser
    attr_accessor :nomis_offender_number

    def initialize(nomis_offender_number:)
      self.nomis_offender_number = nomis_offender_number
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def call
      latest_location = prisons.sample
      {
        offenderNo: nomis_offender_number,
        firstName: Faker::Name.first_name,
        middleNames: Faker::Name.first_name,
        lastName: Faker::Name.last_name,
        dateOfBirth: Faker::Date.between(from: 80.years.ago, to: 20.years.ago),
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

    private

    def prisons
      Location.where(location_type: Location::LOCATION_TYPE_PRISON).all
    end
  end
end
