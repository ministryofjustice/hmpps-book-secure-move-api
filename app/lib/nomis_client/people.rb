# frozen_string_literal: true

class NomisClient
  class People
    class << self
      def get(prison_number)
        attributes_for(
          NomisClient.get("/prisoners/#{prison_number}").parsed.first
        )
      end

      # rubocop:disable Metrics/MethodLength
      def attributes_for(person)
        {
          prison_number: person['offenderNo'],
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
