# frozen_string_literal: true

module People
  class RetrieveActivities
    def self.call(person)
      activities = NomisClient::Activities.get(person.latest_nomis_booking_id)

      activities = activities.map do |nomis_activity|
        Activity.new.build_from_nomis(nomis_activity)
      end

      OpenStruct.new(success?: true, content: activities, errors: nil)
    rescue OAuth2::Error => e
      nomis_error = NomisClient::ApiError.new(status: e.response.status, error_body: e.response.body)

      OpenStruct.new(success?: false, content: [], error: nomis_error)
    end
  end
end
