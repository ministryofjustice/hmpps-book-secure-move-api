namespace :moves do
  desc 'Set all profile ids in all the moves'
  task set_profile_from_person: :environment do
    moves_with_nil_profile = Move.where(profile_id: nil).where.not(person_id: nil)

    total = moves_with_nil_profile.count

    if moves_with_nil_profile.empty?
      puts 'All profiles IDs were already updated.'
      return
    end

    moves_with_nil_profile.find_each(batch_size: 200).with_index do |move, n|
      puts "#{n}/#{total} moves processed ..." if (n % 200).zero? # Show progression

      # The relationship Move -> Person does not exist anymore, so we need to access person this way:
      profile = Person.find(move.person_id).latest_profile

      # update only profile and skip validations: some moves are invalid because of uniqueness of 'date', but that does
      # not impact the correctness of this data migration.
      move.update_attribute(:profile_id, profile.id)
    end

    puts "#{moves_with_nil_profile.count} profile IDs have been successfully updated."
  end
end
