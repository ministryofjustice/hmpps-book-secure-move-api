module Api
  module V1
    class CourtHearingsController < ApiController
      def create
        court_hearing = CourtHearing.create!(court_hearings_attributes)

        if should_save_in_nomis?
          CourtHearings::CreateInNomis.call(move, move.court_hearings)
        else
          Raven.capture_message("CourtHearingsController: Move has not been specified for the court_hearing.id: #{court_hearing.id}", level: 'warning')
        end

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
        @move ||= begin
                    id = params.require(:data).dig(:relationships, :move, :data, :id)

                    return if id.blank?

                    Move.find(id)
                  end
      end

      def should_save_in_nomis?
        move && params['should_save_in_nomis'] == 'true'
      end
    end
  end
end
