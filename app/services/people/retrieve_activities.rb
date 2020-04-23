# frozen_string_literal: true

module People
  class RetrieveActivities
    def self.call(person)
      activities = NomisClient::Activities.get(person.latest_nomis_booking_id)

      activities.map do |activity_json|
        Activity.new.build_from_nomis(activity_json)
      end
    end
  end
end
