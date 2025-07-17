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

      def facial_image_exists?(prison_number)
        return false unless prison_number

        response_data = JSON.parse(fetch_response(prison_number, response_fields: 'currentFacialImageId').body)
        response_data['currentFacialImageId'].present?
      rescue OAuth2::Error, JSON::ParserError => e
        Rails.logger.warn "Failed to fetch image info for #{prison_number}: #{e.message}"
        false
      end

    private

      def fetch_response(prison_number, response_fields: nil)
        url = "/prisoner/#{prison_number}"
        url += "?responseFields=#{response_fields}" if response_fields
        PrisonerSearchApiClient::Base.get(url)
      end

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
        }
      end
    end
  end
end
