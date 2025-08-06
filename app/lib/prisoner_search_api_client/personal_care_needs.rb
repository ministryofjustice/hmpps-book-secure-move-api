# frozen_string_literal: true

module PrisonerSearchApiClient
  class PersonalCareNeeds < PrisonerSearchApiClient::Base
    class << self
      def get(prison_number)
        response = JSON.parse(fetch_response(prison_number).body)
        personal_care_needs = response['personalCareNeeds']
        return [] unless personal_care_needs.is_a?(Array)

        personal_care_needs.map { |personal_care_need| attributes_for(personal_care_need) }
      rescue OAuth2::Error, JSON::ParserError => e
        Rails.logger.warn "Failed to fetch personal care needs for #{prison_number}: #{e.message}"
        []
      end

    private

      def fetch_response(prison_number)
        url = "/prisoner/#{prison_number}?responseFields=personalCareNeeds"
        PrisonerSearchApiClient::Base.get(url)
      end

      def attributes_for(personal_care_need)
        {
          problem_type: personal_care_need['problemType'],
          problem_code: personal_care_need['problemCode'],
          problem_status: personal_care_need['problemStatus'],
          problem_description: personal_care_need['problemDescription'],
          commentText: personal_care_need['commentText'],
          start_date: personal_care_need['startDate'],
          end_date: personal_care_need['endDate'],
        }
      end
    end
  end
end
