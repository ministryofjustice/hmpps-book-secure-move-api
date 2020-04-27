# frozen_string_literal: true

module People
  class RetrieveTimetable
    def self.call(person)
      activities = People::RetrieveActivities.call(person)
      court_hearings = People::RetrieveCourtHearings.call(person)

      timetable = court_hearings + activities

      timetable.sort { |timetable_entry| timetable_entry.start_time }.reverse
    end
  end
end
