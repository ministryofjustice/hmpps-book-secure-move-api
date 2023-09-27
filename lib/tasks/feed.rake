# frozen_string_literal: true

desc 'Exports a JSON feed of yesterday to s3'
task :feed, [:feed_name] => :environment do |_task, args|
  if args[:feed_name].blank?
    puts "No feed name provided. Valid feed names are: all, jpc, #{Feeds::AllWorker.feed_names.join(', ')}"
    next
  end

  feed_name = args[:feed_name].downcase
  unless %w[all jpc].include?(feed_name) || Feeds::AllWorker.feed_names.include?(feed_name)
    puts "#{feed_name} is not a valid feed name. Valid feed names are: all, jpc, #{Feeds::AllWorker.feed_names.join(', ')}"
    next
  end

  Time.zone = 'London'
  date = ENV['REPORT_ON_DATE'] ? Date.parse(ENV['REPORT_ON_DATE']) : Time.zone.yesterday

  case feed_name
  when 'all'
    Feeds::AllWorker.perform_async(date.to_s)
  when 'jpc'
    Feeds::JpcWorker.perform_async(date.to_s)
  else
    Feeds::FeedWorker.perform_async(feed_name, date.to_s)
  end

  puts "#{feed_name == 'all' ? 'All feeds have' : "The #{feed_name} feed has"} been queued."
end
