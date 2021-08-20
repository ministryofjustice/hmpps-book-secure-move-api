# frozen_string_literal: true

module NomisClient
  class CourtHearings < NomisClient::Base
    class PrisonBookingLocationMismatch < StandardError; end

    class << self
      def get(booking_id, start_date, end_date)
        court_hearings_path = "/bookings/#{booking_id}/court-hearings?fromDate=#{start_date.iso8601}&toDate=#{end_date.iso8601}"

        response = NomisClient::Base.get(
          court_hearings_path,
          headers: { 'Page-Limit' => '1000' },
        )

        response.parsed
      end

      def post(booking_id:, court_case_id:, body_params: {})
        court_hearings_path = "/bookings/#{booking_id}/court-cases/#{court_case_id}/prison-to-court-hearings"

        begin
          NomisClient::Base.post(court_hearings_path, body: body_params.to_json)
        rescue OAuth2::Error => e
          if e.response.body =~ /Prison location does not match the bookings location/
            raise PrisonBookingLocationMismatch
          end

          log_exception('CourtHearings::CreateInNomis Error!', court_hearings_path, body_params, e)

          e.response
        end
      rescue PrisonBookingLocationMismatch => e
        Sentry.capture_exception(e, { extra: sentry_extra(court_hearings_path, body_params, e.cause), level: :warning })
        e.cause.response
      end
    end
  end
end
