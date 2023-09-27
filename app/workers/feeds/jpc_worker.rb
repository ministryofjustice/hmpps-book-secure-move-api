# frozen_string_literal: true

class Feeds::JpcWorker
  include Sidekiq::Worker

  def perform(date)
    date = Date.parse(date)

    Sidekiq.logger.info('Generating JPC feed...')
    time_since = TimeSince.new

    feeds = Feeds::Jpc.new(date.beginning_of_day, date.end_of_day).call
    feeds.each do |feed_name, feed_data|
      CloudData::ReportsFeed.new.write(feed_data, "#{feed_name.to_s.pluralize}.jsonl", date)
    end

    Sidekiq.logger.info("Generated JPC feed in #{time_since.get} seconds")
  end
end
