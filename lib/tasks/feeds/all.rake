namespace :feeds do
  desc 'Exports a JSON feed of all possible feed to s3'
  task all: :environment do
    feeds = %w[
      move
    ]

    feeds.each do |feed_name|
      Rake::Task["feeds:#{feed_name}"].invoke
    end
  end
end
