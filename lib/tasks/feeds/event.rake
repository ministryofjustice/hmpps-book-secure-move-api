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

  desc 'Exports the JSON starting from a certain date (inclusive)'
  task events_from_date: :environment do
    start_date_param = ENV.fetch('START_DATE', nil)

    unless start_date_param
      puts 'Please specify the START_DATE ENV variable.'
      puts 'for example: START_DATE="2020-08-29"'
      return
    end

    start_date = Date.parse(start_date_param)

    (start_date..Time.zone.today).each do |day|
      puts "Processing day #{day}"
      feed = Feeds::Event.new(day.beginning_of_day, day.end_of_day).call

      CloudDataFeed.new.write(feed, 'events.jsonl', day)
    end
  end
end
