# frozen_string_literal: true

module NomisClient
  class People
    class << self
      def get(prison_numbers)
        get_response(nomis_offender_numbers: prison_numbers).map do |prisoner|
          attributes_for(prisoner)
        end
      end

      def get_response(nomis_offender_numbers:)
        # The /prisoners endpoint is very quirky - even when passing in 12 offender numbers, it still
        # defaults to paging at (by default) 10 items so set page limit to our offender count
        NomisClient::Base.post(
          '/prisoners',
          headers: { 'Page-Limit' => nomis_offender_numbers.size.to_s },
          body: { 'offenderNos': nomis_offender_numbers }.to_json,
        ).parsed
      end

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
          nationalities: person['nationalities'],
        }
      end
    end
  end
end
