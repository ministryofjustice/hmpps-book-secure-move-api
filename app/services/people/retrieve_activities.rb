# frozen_string_literal: true

module People
  class RetrieveActivities
    def self.call(person)
      activities = NomisClient::Activities.get(person.latest_nomis_booking_id)

      activities.map do |nomis_activity|
        Activity.new.build_from_nomis(nomis_activity)
      end
    end
  end
end
