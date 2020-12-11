namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s notifications to s3'
  task notification: :environment do
    if ENV['REPORT_ON_DATE']
      report_on_date = Date.parse(ENV['REPORT_ON_DATE'])
      updated_at_from = report_on_date.beginning_of_day
      updated_at_to = report_on_date.end_of_day

      feed = Feeds::Notification.new(updated_at_from, updated_at_to).call

      CloudData::ReportsFeed.new.write(feed, 'notifications.jsonl', report_on_date)
    else
      feed = Feeds::Notification.new.call

      CloudData::ReportsFeed.new.write(feed, 'notifications.jsonl')
    end
  end
end
