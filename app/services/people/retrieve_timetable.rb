# frozen_string_literal: true

module People
  class RetrieveTimetable
    def self.call(person)
      activities = People::RetrieveActivities.call(person)
      court_hearings = People::RetrieveCourtHearings.call(person)

      diary_entries = court_hearings + activities

      diary_entries.sort { |entry| entry.start_time }.reverse
    end
  end
end
