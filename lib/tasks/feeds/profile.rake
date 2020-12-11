namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s profiles to s3'
  task profile: :environment do
    if ENV['REPORT_ON_DATE']
      report_on_date = Date.parse(ENV['REPORT_ON_DATE'])
      updated_at_from = report_on_date.beginning_of_day
      updated_at_to = report_on_date.end_of_day

      feed = Feeds::Profile.new(updated_at_from, updated_at_to).call
      CloudData::ReportsFeed.new.write(feed, 'profiles.jsonl', report_on_date)
    else
      feed = Feeds::Profile.new.call
      CloudData::ReportsFeed.new.write(feed, 'profiles.jsonl')
    end
  end
end
