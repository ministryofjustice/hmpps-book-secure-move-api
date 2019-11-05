# frozen_string_literal: true

module NomisClient
  class People
    class << self
      def get(prison_numbers)
        response(prison_numbers).map do |prisoner|
          attributes_for(prisoner)
        end
      end

      def get_response(nomis_offender_numbers:)
        NomisClient::Base.post(
          '/prisoners',
          body: { 'offenderNos': nomis_offender_numbers }.to_json,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          }
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

      private

      def response(prison_numbers)
        get_response(nomis_offender_numbers: prison_numbers)
      end
    end
  end
end
