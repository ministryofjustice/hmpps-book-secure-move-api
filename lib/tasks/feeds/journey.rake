namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s journeys to s3'
  task journey: :environment do
    if ENV['REPORT_ON_DATE']
      report_on_date = Date.parse(ENV['REPORT_ON_DATE'])
      updated_at_from = report_on_date.beginning_of_day
      updated_at_to = report_on_date.end_of_day

      feed = Feeds::Journey.new(updated_at_from, updated_at_to).call

      CloudDataFeed.new.write(feed, 'journeys.jsonl', report_on_date)
    else
      feed = Feeds::Journey.new.call

      CloudDataFeed.new.write(feed, 'journeys.jsonl')
    end
  end
end
