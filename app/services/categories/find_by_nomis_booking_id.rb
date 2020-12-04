module Categories
  class FindByNomisBookingId
    attr_reader :nomis_booking_id

    def initialize(nomis_booking_id)
      @nomis_booking_id = nomis_booking_id
    end

    def call
      Category.find_by(key: booking_details[:category_code]) if nomis_booking_id.present?
    end

  private

    def booking_details
      @booking_details ||= NomisClient::BookingDetails.get(nomis_booking_id)
    end
  end
end
