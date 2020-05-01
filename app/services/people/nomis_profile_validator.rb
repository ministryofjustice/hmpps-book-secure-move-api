module People
  class NomisProfileValidator
    include ActiveModel::Validations

    attr_reader :latest_nomis_booking_id

    validates :latest_nomis_booking_id, presence: true

    def initialize(profile)
      @latest_nomis_booking_id = profile.latest_nomis_booking_id
    end
  end
end
