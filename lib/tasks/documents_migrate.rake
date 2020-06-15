# TODO: Remove this once we've migrated all moves to be on a profile
namespace :documents do
  desc 'Moves all document relationships to a Profile'
  task migrate: :environment do
    total = Document.count

    Document.includes(move: [:profile]).find_each(batch_size: 200).with_index do |document, n|
      puts "#{n}/#{total} documents moved to profile ..." if (n % 200).zero?
      DocumentMover.new(document).call
    end

    puts "#{total} documents have been successfully moved to the profile."
  end
end
