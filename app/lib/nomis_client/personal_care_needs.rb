# frozen_string_literal: true

module NomisClient
  class PersonalCareNeeds < NomisClient::Base
    PERSONAL_CARE_TYPES = 'MATSTAT,PHY,DISAB'

    class << self
      def get(nomis_offender_numbers:, personal_care_types: PERSONAL_CARE_TYPES)
        get_response(nomis_offender_numbers:, personal_care_types:).map { |personal_care_needs|
          personal_care_needs['personalCareNeeds'].map do |personal_care_need_attributes|
            attributes_for(personal_care_needs['offenderNo'], personal_care_need_attributes)
          end
        }.flatten
      end

      def get_response(nomis_offender_numbers:, personal_care_types:)
        NomisClient::Base.post(
          "/bookings/offenderNo/personal-care-needs?type=#{personal_care_types}",
          body: nomis_offender_numbers.to_json,
        ).parsed
      end

      def attributes_for(offender_no, personal_care_need)
        {
          offender_no:,
          problem_type: personal_care_need['problemType'],
          problem_code: personal_care_need['problemCode'],
          problem_status: personal_care_need['problemStatus'],
          problem_description: personal_care_need['problemDescription'],
          start_date: personal_care_need['startDate'],
          end_date: personal_care_need['endDate'],
          comments: personal_care_need['commentText'],
        }
      end
    end
  end
end
