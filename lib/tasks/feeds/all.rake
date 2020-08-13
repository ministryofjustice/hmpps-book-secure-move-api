namespace :feeds do
  desc 'Exports a JSON feed of all possible feeds to s3'
  task all: :environment do
    feeds = %w[
      move
      profile
      person
      journey
      notification
    ]

    feeds.each do |feed_name|
      puts "Generating #{feed_name} feed ..."

      Rake::Task["feeds:#{feed_name}"].invoke
    end
  end
end
