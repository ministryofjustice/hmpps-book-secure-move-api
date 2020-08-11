module Feeds
  class Move
    def initialize(updated_at_from = nil, updated_at_to = nil)
      @updated_at_from = updated_at_from || Time.zone.now.beginning_of_day - 1.day
      @updated_at_to = updated_at_to || Time.zone.now.end_of_day - 1.day

      @feed = []
    end

    def call
      ::Move.updated_at_from_and_to(@updated_at_from, @updated_at_to).find_each do |move|
        @feed << move.for_feed.to_json
      end

      @feed.join("\n")
    end
  end
end
