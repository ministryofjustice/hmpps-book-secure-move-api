module PrisonerSearchApiClient
  class Prisoner < PrisonerSearchApiClient::Base
    class << self
      def get(prison_number)
        return nil unless prison_number

        response_data = JSON.parse(fetch_response(prison_number).body)
        attributes_for(response_data)
      rescue OAuth2::Error, JSON::ParserError => e
        Rails.logger.warn "Failed to fetch prisoner data for #{prison_number}: #{e.message}"
        nil
      end

      def fetch_response(prison_number)
        PrisonerSearchApiClient::Base.get("/prisoner/#{prison_number}")
      end

    private

      def attributes_for(person)
        {
          prison_number: person['prisonerNumber'],
          latest_booking_id: person['bookingId'],
          last_name: person['lastName'],
          first_name: person['firstName'],
          middle_names: person['middleNames'],
          date_of_birth: person['dateOfBirth'],
          aliases: person['aliases'],
          pnc_number: person['pncNumber'],
          cro_number: person['croNumber'],
          gender: person['gender'],
          ethnicity: person['ethnicity'],
          nationalities: person['nationality'], # NOTE: singular in Prisoner Search API
        }
      end
    end
  end
end
