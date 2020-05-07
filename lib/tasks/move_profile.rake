namespace :moves do
  desc 'Set all profile ids in all the moves'
  task set_profiles: :environment do
    moves = Move.where(profile_id: nil).includes(person: :profiles)

    total = moves.count

    if moves.empty?
      puts 'All profiles IDs were already updated.'
      return
    end

    moves.find_each(batch_size: 200).with_index do |move, n|
      puts "#{n}/#{total} moves processed ..." if (n % 200).zero? # Show progression


      # TODO: the rails rel Move -> Person does not exist anymore, so we'll need to use something like
      # person = Person.find(move_id: person.move_id)
      # profile = person.profiles.order(:updated_at).last

      # TODO: move.person does not exist anymore, see TODO above!
      profile = move.person.profiles.order(:updated_at).last # Take the profile that was most recently updated

      # update only profile and skip validations: some moves are invalid because of uniqueness of 'date', but that does
      # not impact the correctness of this data migration.
      move.update_attribute(:profile_id, profile.id)
    end

    puts "#{moves.count} profile IDs have been successfully updated."
  end
end
