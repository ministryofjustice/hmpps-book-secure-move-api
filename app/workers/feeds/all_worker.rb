# frozen_string_literal: true

module Feeds
  class AllWorker
    include Sidekiq::Worker

    def perform(date)
      date = Date.parse(date)
      self.class.feed_names.each { |feed_name| Feeds::FeedWorker.perform_async(feed_name, date) }
    end

    def self.feed_names
      %w[move profile person journey notification event]
    end
  end
end
