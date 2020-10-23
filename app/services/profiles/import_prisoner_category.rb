module Profiles
  class ImportPrisonerCategory
    def initialize(profile)
      @profile = profile
      @nomis_booking_id = @profile&.person&.latest_nomis_booking_id
    end

    def call
      @profile.update(NomisClient::BookingDetails.get(@nomis_booking_id))
    end
  end
end
