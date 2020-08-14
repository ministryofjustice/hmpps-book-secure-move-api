namespace :feeds do
  desc 'Exports a JSON feed of yesterday\'s moves to s3'
  task move: :environment do
    feed = Feeds::Move.new.call

    CloudDataFeed.new.write(feed, 'moves.json')
  end
end
