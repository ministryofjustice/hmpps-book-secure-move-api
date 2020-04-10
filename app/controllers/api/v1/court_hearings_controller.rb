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
          :nomis_case_number,
          :nomis_case_id,
          :case_type,
          :comments,
        )
      end

      def move
        return if relationship_params.blank?

        id = relationship_params.require(:moves).require(:data).permit(:id, :type)[:id]

        Move.find(id)
      end

      def relationship_params
        @relationship_params ||=
          begin
            if params.require(:data).fetch(:relationships, nil)
              params.require(:data).require(:relationships)
            else
              {}
            end
          end
      end
    end
  end
end
