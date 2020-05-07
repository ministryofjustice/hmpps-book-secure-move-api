namespace :moves do
  desc 'Set all profile ids in all the moves'
  task set_profiles: :environment do
    moves = Move.where(profile_id: nil)

    total = moves.count

    if moves.empty?
      puts 'All profiles IDs were already updated.'
      return
    end

    moves.find_each(batch_size: 200).with_index do |move, n|
      puts "#{n}/#{total} moves processed ..." if (n % 200).zero? # Show progression

      # The relationship Move -> Person does not exist anymore, so we need to access person this way:
      person = Person.find(move.person_id)

      profile = person.profiles.order(:updated_at).last

      # update only profile and skip validations: some moves are invalid because of uniqueness of 'date', but that does
      # not impact the correctness of this data migration.
      move.update_attribute(:profile_id, profile.id)
    end

    puts "#{moves.count} profile IDs have been successfully updated."
  end
end
