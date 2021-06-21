module Api
  class CourtHearingsController < ApiController
    def create
      court_hearing = CourtHearing.create!(court_hearings_attributes)

      Rails.logger.info("Received court hearing #{request.body.read}")

      request.body.rewind

      Rails.logger.info("Created a court hearing #{court_hearing.attributes.to_json}")

      if should_save_in_nomis?
        log_attributes = CourtHearings::CreateInNomis.call(move, move.court_hearings)

        Rails.logger.info("Tried to save a court hearing to nomis #{log_attributes.to_json}")
      else
        Rails.logger.info("Did not save to nomis #{court_hearing.attributes.to_json}")
      end

      render_json court_hearing, serializer: CourtHearingSerializer, status: :created
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
      save_to_nomis = params.fetch('do_not_save_to_nomis', 'false') != 'true'

      move && save_to_nomis
    end
  end
end
