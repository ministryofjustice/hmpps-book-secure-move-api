# frozen_string_literal: true

module People
  class RetrieveTimetable
    def self.call(person, start_date, end_date)
      activities_response = People::RetrieveActivities.call(person, start_date, end_date)
      return activities_response unless activities_response.success?

      court_hearings_response = People::RetrieveCourtHearings.call(person, start_date, end_date)
      return court_hearings_response unless court_hearings_response.success?

      timetable = court_hearings_response.content + activities_response.content
      timetable = timetable.sort_by(&:start_time)

      OpenStruct.new(success?: true, content: timetable, errors: nil)
    end
  end
end
