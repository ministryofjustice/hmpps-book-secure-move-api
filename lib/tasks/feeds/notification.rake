namespace :feeds do
  desc 'Exports a JSON feed of all profiles to s3'
  task notification: :environment do
    feed = Feeds::Notification.new.call

    CloudDataFeed.new.write(feed, 'notifications.json')
  end
end
