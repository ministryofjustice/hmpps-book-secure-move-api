namespace :prisoner_category do
  desc 'Refresh prisoner category'
  task refresh_data: :environment do
    profiles = Profile.joins(:person).where.not(people: { latest_nomis_booking_id: nil })
    count = profiles.count
    i = 1

    puts "Refreshing #{count} profiles"
    profiles.find_each do |profile|
      Profiles::ImportPrisonerCategory.new(profile).call
      puts "processed #{i} of #{count}: #{profile.id} -> #{profile.category}"
      i += 1
    end
  end
end
