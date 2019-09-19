# frozen_string_literal: true

require 'nomis/faker'

module NomisClient
  class People
    class << self
      def get(prison_number)
        attributes_for(
          get_response(nomis_offender_number: prison_number).first
        )
      end

      def get_response(nomis_offender_number:)
        NomisClient::Base.get(
          "/prisoners/#{nomis_offender_number}",
          params: {},
          headers: { 'Page-Limit' => '1000' }
        ).parsed
      end

      # rubocop:disable Metrics/MethodLength
      def attributes_for(person)
        {
          prison_number: person['offenderNo'],
          latest_booking_id: person['latestBookingId'],
          last_name: person['lastName'],
          first_name: person['firstName'],
          middle_names: person['middleNames'],
          date_of_birth: person['dateOfBirth'],
          aliases: person['aliases'],
          pnc_number: person['pncNumber'],
          cro_number: person['croNumber'],
          gender: person['sexCode'],
          ethnicity: person['ethnicity'],
          nationalities: person['nationalities']
        }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
