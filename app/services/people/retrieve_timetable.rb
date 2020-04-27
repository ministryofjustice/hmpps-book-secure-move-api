# frozen_string_literal: true

module People
  class RetrieveTimetable
    def self.call(person)
      activities_response = People::RetrieveActivities.call(person)
      return activities_response unless activities_response.success?

      court_hearings_response = People::RetrieveCourtHearings.call(person)
      return court_hearings_response unless court_hearings_response.success?

      timetable = court_hearings_response.content + activities_response.content
      timetable.sort_by(&:start_time).reverse

      OpenStruct.new(success?: true, content: timetable, errors: nil)
    end
  end
end
