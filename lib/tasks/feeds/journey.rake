namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s journeys to s3'
  task journey: :environment do
    feed_journeys = Feeds::Journey.new.call

    CloudDataFeed.new.write(feed_journeys, 'journeys.jsonl')
  end
end
