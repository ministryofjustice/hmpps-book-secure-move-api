module Profiles
  class ImportPrisonerCategory
    def initialize(profile)
      @profile = profile
      @nomis_booking_id = @profile&.person&.latest_nomis_booking_id
    end

    def call
      @profile.update(GetPrisonerCategoryAttributes.new(@nomis_booking_id).call) if @nomis_booking_id.present?
    end
  end
end
