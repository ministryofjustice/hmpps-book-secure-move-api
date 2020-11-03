module Api
  module Reference
    class CategoriesController < ApiController
      # PERMITTED_FILTER_PARAMS = %i[person_id].freeze

      def index
        render_json Category.order(:key), serializer: CategorySerializer, status: :ok
      end

    private

      # def filter_params
      #   params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
      # end
      #
      # def person
      #   Person.find(filter_params[:person_id])
      # end
      #
      # def all_categories
      #
      # end
      #
      # def person_categories
      #   booking_details = NomisClient::BookingDetails.get(person.latest_nomis_booking_id)
      #
      #   if booking_details[:category_code].present?
      #     [Category.find_by(key: booking_details[:category_code])].compact
      #   else
      #     []
      #   end
      # end
    end
  end
end