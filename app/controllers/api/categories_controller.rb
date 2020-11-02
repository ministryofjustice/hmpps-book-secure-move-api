module Api
  class CategoriesController < ApiController
    PERMITTED_FILTER_PARAMS = %i[person_id].freeze

    def index
      render_json categories, serializer: CategorySerializer, status: :ok
    end

  private

    def filter_params
      params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
    end

    def person
      Person.find(filter_params[:person_id])
    end

    def categories
      booking_details = NomisClient::BookingDetails.get(person.latest_nomis_booking_id)

      if booking_details[:category_code].present?
        [Category.build_from_nomis(booking_details)]
      else
        []
      end
    end
  end
end
