# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApiController
      def index
        moves_params = Moves::ParamsValidator.new(filter_params, params[:sort] || {})
        if moves_params.valid?
          moves = Moves::Finder.new(filter_params, current_ability, params[:sort] || {}).call
          # Excludes potentially many court hearing documents to reduce the request size. This was requested specifically by the frontend team.
          paginate moves, include: MoveSerializer::INCLUDED_ATTRIBUTES.dup.except(:court_hearings)
        else
          render json: { error: moves_params.errors }, status: :bad_request
        end
      end

      def show
        move = find_move

        render_move(move, 200)
      end

      def create
        move = Move.new(move_attributes)
        authorize!(:create, move)

        ActiveRecord::Base.transaction do
          move.save!
          Moves::CreateCourtHearings.new(move, court_hearings_params).call if court_hearings_params.present?
        end

        Notifier.prepare_notifications(topic: move, action_name: 'create')

        render_move(move, 201)
      end

      def update
        move = find_move
        raise ActiveRecord::ReadOnlyRecord, 'Can\'t change moves coming from Nomis' if move.from_nomis?

        # NB: rather than update directly, we need to detect whether the move status has changed before saving the record
        move.assign_attributes(patch_move_attributes)
        status_changed = move.status_changed?
        move.save!

        Notifier.prepare_notifications(topic: move, action_name: status_changed ? 'update_status' : 'update')
        render_move(move, 200)
      end

      def destroy
        move = find_move
        move.destroy! # TODO: we probably should not be destroying moves
        Notifier.prepare_notifications(topic: move, action_name: 'destroy')
        render_move(move, 200)
      end

    private

      PERMITTED_FILTER_PARAMS = %i[
        date_from date_to created_at_from created_at_to location_type status from_location_id to_location_id supplier_id
      ].freeze
      PERMITTED_MOVE_PARAMS = [
        :type,
        attributes: %i[date time_due status move_type additional_information
                       cancellation_reason cancellation_reason_comment
                       reason_comment move_agreed move_agreed_by date_from date_to],
        relationships: {},
      ].freeze
      PERMITTED_PATCH_MOVE_PARAMS = [attributes: %i[date time_due status additional_information
                                                    cancellation_reason cancellation_reason_comment
                                                    reason_comment move_agreed move_agreed_by date_from date_to]].freeze

      def court_hearings_params
        return {} if relationship_params.fetch('court_hearings', {}).blank?

        relationship_params.require(:court_hearings).require(:data).map do |court_hearing_params|
          court_hearing_params.require(:attributes).permit(
            :start_time,
            :case_start_date,
            :nomis_case_number,
            :nomis_case_id,
            :court_type,
            :comments,
          )
        end
      end

      def relationship_params
        @relationship_params ||= params.require(:data).require(:relationships)
      end

      def filter_params
        params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
      end

      def move_params
        params.require(:data).permit(PERMITTED_MOVE_PARAMS).to_h
      end

      def patch_move_params
        params.require(:data).permit(PERMITTED_PATCH_MOVE_PARAMS).to_h
      end

      def move_attributes
        # moves are always created against the latest_profile for the person
        move_params[:attributes].merge(
          person: Person.find(move_params.dig(:relationships, :person, :data, :id)),
          from_location: Location.find(move_params.dig(:relationships, :from_location, :data, :id)),
          to_location: Location.find_by(id: move_params.dig(:relationships, :to_location, :data, :id)),
          documents: Document.where(id: (move_params.dig(:relationships, :documents, :data) || []).map { |doc| doc[:id] }),
          prison_transfer_reason: PrisonTransferReason.find_by(id: move_params.dig(:relationships, :prison_transfer_reason, :data, :id)),
        )
      end

      def patch_move_attributes
        patch_move_params[:attributes]
      end

      def render_move(move, status)
        render json: move, status: status, include: MoveSerializer::INCLUDED_ATTRIBUTES
      end

      def find_move
        Move
          .accessible_by(current_ability)
          .includes(:from_location, :to_location, person: { profiles: %i[gender ethnicity] })
          .find(params[:id])
      end
    end
  end
end
