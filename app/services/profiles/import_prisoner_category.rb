module Profiles
  class ImportPrisonerCategory
    def initialize(profile)
      @profile = profile
      @nomis_booking_id = @profile&.person&.latest_nomis_booking_id
    end

    def call
      booking_details = NomisClient::BookingDetails.get(@nomis_booking_id)
      category = Category.find_by(key: booking_details[:category_code])

      @profile.update(category: category)
    end
  end
end
