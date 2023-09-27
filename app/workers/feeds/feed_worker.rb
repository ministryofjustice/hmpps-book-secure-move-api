# frozen_string_literal: true

class Feeds::FeedWorker
  include Sidekiq::Worker

  def perform(feed_name, date)
    date = Date.parse(date)

    Sidekiq.logger.info("Generating #{feed_name} feed...")
    time_since = TimeSince.new

    feed = "Feeds::#{feed_name.titleize}".constantize.new(date.beginning_of_day, date.end_of_day).call
    CloudData::AnalyticalPlatformFeed.new.write(feed, feed_name.pluralize, date)

    Sidekiq.logger.info("Generated #{feed_name} feed in #{time_since.get} seconds")
  end
end
