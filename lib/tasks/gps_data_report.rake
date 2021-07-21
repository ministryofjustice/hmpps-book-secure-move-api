# frozen_string_literal: true

desc 'Posts a report of the past weeks GPS data to slack'
task feed: :environment do
  GPSReportWorker.perform_async

  puts 'The GPS data report worker been queued.'
end
