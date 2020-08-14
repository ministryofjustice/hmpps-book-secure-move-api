namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s events to s3'
  task event: :environment do
    feed = Feeds::Event.new.call

    CloudDataFeed.new.write(feed, 'events.jsonl')
  end
end
