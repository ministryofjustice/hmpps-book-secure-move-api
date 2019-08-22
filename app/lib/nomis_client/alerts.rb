# frozen_string_literal: true

class NomisClient
  class Alerts
    class << self
      def get(prison_number)
        attributes_for(
          NomisClient.get("/bookings/offenderNo/#{prison_number}/alerts").parsed
        )
      end

      def attributes_for(alerts)
        alerts
      end
    end
  end
end
