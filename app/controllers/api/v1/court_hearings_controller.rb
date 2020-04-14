module Api
  module V1
    class CourtHearingsController < ApiController
      def create
        court_hearing = CourtHearing.create!(court_hearings_attributes)

        render json: court_hearing, status: :created
      end

    private

      def court_hearings_attributes
        court_hearings_params.merge(move: move)
      end

      def court_hearings_params
        params.require(:data).require(:attributes).permit(
          :start_time,
          :case_start_date,
          :case_number,
          :nomis_case_id,
          :case_type,
          :comments,
        )
      end

      def move
        id = params.require(:data).dig(:relationships, :moves, :data, :id)

        return if id.blank?

        Move.find(id)
      end
    end
  end
end
