namespace :prisoner_category do
  desc 'Refresh prisoner category'
  task refresh_data: :environment do
    profiles = Profile.joins(:person).where.not(people: { latest_nomis_booking_id: nil })
    count = profiles.count

    puts "Refreshing #{count} profiles"
    profiles.find_each.with_index do |profile, i|
      Profiles::ImportPrisonerCategory.new(profile).call
      puts "processed #{i+1} of #{count}: #{profile.id} -> #{profile.category}"
    end
  end
end
