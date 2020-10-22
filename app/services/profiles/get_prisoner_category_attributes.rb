module Profiles
  class GetPrisonerCategoryAttributes
    def initialize(nomis_booking_id)
      @nomis_booking_id = nomis_booking_id
    end

    def call
      if @nomis_booking_id.present?
        NomisClient::PrisonerCategory.get(@nomis_booking_id)
      else
        {
          category: nil,
          category_code: nil,
        }
      end
    end
  end
end
