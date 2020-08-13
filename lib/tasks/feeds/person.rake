namespace :feeds do
  desc 'Exports a JSON feed of all persons to s3'
  task person: :environment do
    feed = Feeds::Person.new.call

    CloudDataFeed.new.write(feed, 'people.json')
  end
end
