namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s people to s3'
  task person: :environment do
    feed = Feeds::Person.new.call

    CloudDataFeed.new.write(feed, 'people.jsonl')
  end
end
