namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s notifications to s3'
  task notification: :environment do
    feed = Feeds::Notification.new.call

    CloudDataFeed.new.write(feed, 'notifications.json')
  end
end
