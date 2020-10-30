namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s notifications to s3'
  task notification: :environment do
    if ENV['REPORT_ON_DATE']
      report_on_date = Date.parse(ENV['REPORT_ON_DATE'])
      created_at_from = report_on_date.beginning_of_day
      created_at_to = report_on_date.end_of_day

      feed = Feeds::Notification.new(created_at_from, created_at_to).call

      CloudDataFeed.new.write(feed, 'notifications.jsonl', report_on_date)
    else
      feed = Feeds::Notification.new.call

      CloudDataFeed.new.write(feed, 'notifications.jsonl')
    end
  end
end
