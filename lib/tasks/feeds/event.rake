namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s events to s3'
  task event: :environment do
    if ENV['REPORT_ON_DATE']
      report_on_date = Date.parse(ENV['REPORT_ON_DATE'])
      updated_at_from = report_on_date.beginning_of_day
      updated_at_to = report_on_date.end_of_day

      feed = Feeds::Event.new(updated_at_from, updated_at_to).call
      CloudDataFeed.new.write(feed, 'events.jsonl', report_on_date)
    else
      feed = Feeds::Event.new.call
      CloudDataFeed.new.write(feed, 'events.jsonl')
    end
  end
end
