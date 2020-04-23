module NomisClient
  class Activities < NomisClient::Base
    class << self
      def get(booking_id, start_date = Date.today, end_date = Date.today)
        activities_path = "/bookings/#{booking_id}/activities?fromDate=#{start_date.iso8601}&toDate=#{end_date.iso8601}"

        activities = []

        paginate_through(activities_path) do |_activity_json|
          activities << activities
        end

        activities
      end
    end
  end
end
