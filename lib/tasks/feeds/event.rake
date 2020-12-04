namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s events to s3'
  task event: :environment do
    if ENV['REPORT_ON_DATE']
      report_on_date = Date.parse(ENV['REPORT_ON_DATE'])
      created_at_from = report_on_date.beginning_of_day
      created_at_to = report_on_date.end_of_day

      feed = Feeds::Event.new(created_at_from, created_at_to).call
      CloudDataFeed.new.write(feed, 'events.jsonl', report_on_date)
    else
      feed = Feeds::Event.new.call
      CloudDataFeed.new.write(feed, 'events.jsonl')
    end
  end
end
