# frozen_string_literal: true

module Feeds
  class AllWorker
    include Sidekiq::Worker

    def perform(date)
      date = Date.parse(date)

      Sidekiq.logger.info('Generating analytics feeds...')
      time_since = TimeSince.new

      feeds = Feeds::All.new(date.beginning_of_day, date.end_of_day).call
      feeds.each do |feed_name, feed_data|
        CloudData::AnalyticalPlatformFeed.new.write(feed_data, feed_name.to_s.pluralize, date)
      end

      Sidekiq.logger.info("Generated analytics feeds in #{time_since.get} seconds")
    end

    def self.feed_names
      %w[move profile person journey notification event]
    end
  end
end
