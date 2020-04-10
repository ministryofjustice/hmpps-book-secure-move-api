module Api
  module V1
    class CourtHearingsController < ApiController
      def create
        court_hearing = CourtHearing.create!(court_hearings_params)

        render json: court_hearing, status: :created
      end

    private

      def court_hearings_params
        params.require(:data).require(:attributes).permit(
          :start_time,
          :case_start_date,
          :nomis_case_number,
          :nomis_case_id,
          :case_type,
          :comments,
        )
      end
    end
  end
end
