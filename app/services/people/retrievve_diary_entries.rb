# frozen_string_literal: true

module People
  class RetrieveDiaryEntries
    def self.call(person)
      court_hearings = People::CourtHearings.call(person)
      activities = People::Activities.call(person)

      diary_entries = court_hearings + activities

      diary_entries.sort(&:start_time)
    end
  end
end
