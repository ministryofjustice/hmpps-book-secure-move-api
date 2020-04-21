# frozen_string_literal: true

module NomisClient
  class CourtCases < NomisClient::Base
    class << self
      DEFAULT_FILTER_PARAMS = {
        active: 'true',
      }.freeze

      def get(booking_id, filter_params = DEFAULT_FILTER_PARAMS)
        query = filter_query(filter_params)

        court_cases_route = "/bookings/#{booking_id}/court-cases#{query}"

        NomisClient::Base.get(court_cases_route).body
      end

    private

      def filter_query(filter_params)
        return if filter_params.blank?

        "?activeOnly=#{filter_params.fetch(:active, 'true')}"
      end
    end
  end
end
