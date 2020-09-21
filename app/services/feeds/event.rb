module Feeds
  class Event
    def initialize(updated_at_from = nil, updated_at_to = nil)
      @updated_at_from = updated_at_from || Time.zone.yesterday.beginning_of_day
      @updated_at_to = updated_at_to || Time.zone.yesterday.end_of_day

      @feed = []
    end

    def call
      ::GenericEvent.includes(:eventable).updated_at_range(@updated_at_from, @updated_at_to).find_each do |event|
        @feed << event.for_feed.to_json
      end

      @feed.join("\n")
    end
  end
end
