namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s profiles to s3'
  task profile: :environment do
    feed = Feeds::Profile.new.call

    CloudDataFeed.new.write(feed, 'profiles.json')
  end
end
