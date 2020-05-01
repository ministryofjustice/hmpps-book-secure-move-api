module NomisClient
  class Activities < NomisClient::Base
    class << self
      def get(booking_id, start_date, end_date)
        activities_path = "/bookings/#{booking_id}/activities?fromDate=#{start_date.iso8601}&toDate=#{end_date.iso8601}"

        response = NomisClient::Base.get(
          activities_path,
          headers: { 'Page-Limit' => '1000' },
        )

        response.parsed
      end
    end
  end
end
