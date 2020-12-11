namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s people to s3'
  task person: :environment do
    if ENV['REPORT_ON_DATE']
      report_on_date = Date.parse(ENV['REPORT_ON_DATE'])
      updated_at_from = report_on_date.beginning_of_day
      updated_at_to = report_on_date.end_of_day

      feed = Feeds::Person.new(updated_at_from, updated_at_to).call
      CloudData::ReportsFeed.new.write(feed, 'people.jsonl', report_on_date)
    else
      feed = Feeds::Person.new.call
      CloudData::ReportsFeed.new.write(feed, 'people.jsonl')
    end
  end
end
