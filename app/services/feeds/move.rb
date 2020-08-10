module Feeds
  class MoveReportGenerator
    def initialize(start_time: nil, end_time:)
      @start_time = start_time || Time.zone.now.beginning_of_day - 1.day
      @end_time = end_time || Time.zone.now.end_of_day - 1.day
      @inclusive_range = @start_time..@end_time
    end

    def call
      moves.find_each(&:for_feed)
    end

  private

    def moves
      Move.where(updated_at: @inclusive_range).includes(
        :suppliers,
        :from_location,
        :to_location,
      )
    end
  end
end
