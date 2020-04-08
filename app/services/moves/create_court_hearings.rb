module Moves
  class CreateCourtHearings
    attr_reader :move, :court_hearings_params

    def initialize(move, court_hearings_params)
      @move = move
      @court_hearings_params = court_hearings_params
    end

    def call
      return unless move.from_prison_to_court?

      court_hearings_params.map do |court_hearing_attributes|
        move.court_hearings.create(court_hearing_attributes)
      end
    end
  end
end
