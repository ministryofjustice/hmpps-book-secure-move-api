module Feeds
  class Notification
    def initialize(created_at_from = nil, created_at_to = nil)
      @created_at_from = created_at_from || Time.zone.yesterday.beginning_of_day
      @created_at_to = created_at_to || Time.zone.yesterday.end_of_day

      @feed = []
    end

    def call
      ::Notification.created_at_range(@created_at_from, @created_at_to).find_each do |notification|
        @feed << notification.for_feed.to_json
      end

      @feed.join("\n")
    end
  end
end
