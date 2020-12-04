namespace :prisoner_category do
  desc 'Refresh prisoner category'
  task refresh_data: :environment do
    profiles = Profile.joins(:person).where.not(people: { latest_nomis_booking_id: nil })
    count = profiles.count

    puts "Refreshing #{count} profiles"
    profiles.find_each.with_index do |profile, i|
      latest_nomis_booking_id = profile&.person&.latest_nomis_booking_id
      if latest_nomis_booking_id.present?
        profile.category = Categories::FindByNomisBookingId.new(latest_nomis_booking_id).call
        profile.save(touch: false) # NB: don't mass-update the updated_at timestamp to prevent a catastrophe in JPC/CDI reports
      end

      puts "processed #{i + 1} of #{count}: #{profile.id} -> #{profile.category}"
    end
  end
end
