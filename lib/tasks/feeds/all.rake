namespace :feeds do
  desc 'Exports a JSON feed of all possible feeds to s3'
  task all: :environment do
    feeds = %w[
      move
      profile
      person
      journey
      notification
      event
    ]

    feeds.each do |feed_name|
      puts "Generating #{feed_name} feed..."

      start_time = Time.zone.now
      Rake::Task["feeds:#{feed_name}"].invoke
      end_time = Time.zone.now

      elapsed_time = (end_time - start_time).seconds

      puts "Generated #{feed_name} feed in #{elapsed_time} seconds"
    end
  end
end
