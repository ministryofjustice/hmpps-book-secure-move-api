namespace :feeds do
  desc 'Exports a JSON feed of all profiles to s3'
  task move: :environment do
    feed = Feeds::Profile.new.call

    CloudDataFeed.new.write(feed, 'profiles.json')
  end
end
