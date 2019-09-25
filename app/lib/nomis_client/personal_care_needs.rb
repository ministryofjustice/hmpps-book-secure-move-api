# frozen_string_literal: true

module NomisClient
  class PersonalCareNeeds < NomisClient::Base
    class << self
      def get(booking_number)
        get_response(booking_number: booking_number).parsed.map do |personal_care_need|
          attributes_for(personal_care_need)
        end
      end

      def get_response(booking_number:)
        NomisClient::Base.get("/bookings/#{booking_number}/personal-care-needs")
      end

      def attributes_for(personal_care_need)
        {
          problem_type: personal_care_need['problemType'],
          problem_code: personal_care_need['problemCode'],
          problem_status: personal_care_need['problemStatus'],
          problem_description: personal_care_need['problemDescription'],
          start_date: personal_care_need['startDate'],
          end_date: personal_care_need['endDate']
        }
      end
    end
  end
end
