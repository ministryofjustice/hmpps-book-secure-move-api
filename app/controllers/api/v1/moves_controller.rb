# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApiController
      def index
        moves_params = Moves::ParamsValidator.new(filter_params, params[:sort] || {})

        if moves_params.valid?
          moves = Moves::Finder.new(filter_params, current_ability, params[:sort] || {}).call
          # Excludes potentially many court hearing documents to reduce the request size. This was requested specifically by the frontend team.

          serialization_params = { include: MoveSerializer::INCLUDED_ATTRIBUTES.dup.except(:court_hearings), fields: MoveSerializer::INCLUDED_FIELDS }

          paginate moves, serialization_params
        else
          render json: { error: moves_params.errors }, status: :bad_request
        end
      end

      def show
        render_move(move, 200)
      end

      def create
        move = Move.new(move_attributes)
        authorize!(:create, move)
        move.save!

        Notifier.prepare_notifications(topic: move, action_name: 'create')

        render_move(move, 201)
      end

      def update
        raise ActiveRecord::ReadOnlyRecord, 'Can\'t change moves coming from Nomis' if move.from_nomis?

        # NB: rather than update directly, we need to detect whether the move status has changed before saving the record

        move.assign_attributes(patch_move_attributes)
        status_changed = move.status_changed?
        move.save!

        Notifier.prepare_notifications(topic: move, action_name: status_changed ? 'update_status' : 'update')
        render_move(move, 200)
      end

      def destroy
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
      PERMITTED_PATCH_MOVE_PARAMS = [
        :type,
        attributes: %i[date time_due status additional_information
                       cancellation_reason cancellation_reason_comment
                       reason_comment move_agreed move_agreed_by date_from date_to],
        relationships: {},
      ].freeze

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
        person = Person.find(move_params.dig(:relationships, :person, :data, :id))

        move_params[:attributes].merge(
          person_id: person.id,
          profile: person.latest_profile,
          from_location: Location.find(move_params.dig(:relationships, :from_location, :data, :id)),
          to_location: Location.find_by(id: move_params.dig(:relationships, :to_location, :data, :id)),
          documents: Document.where(id: (move_params.dig(:relationships, :documents, :data) || []).map { |doc| doc[:id] }),
          court_hearings: CourtHearing.where(id: (move_params.dig(:relationships, :court_hearings, :data) || []).map { |court_hearing| court_hearing[:id] }),
          prison_transfer_reason: PrisonTransferReason.find_by(id: move_params.dig(:relationships, :prison_transfer_reason, :data, :id)),
        )
      end

      # 1. Frontend specifies empty docs: update documents to be empty
      # 2. Frontend does not include document relationship: don't update documents at all
      def patch_move_attributes
        attributes = patch_move_params.fetch(:attributes, {})
        document_ids = patch_move_params.dig(:relationships, :documents, :data)

        return attributes if document_ids.nil?

        document_ids = document_ids.map { |doc| doc[:id] }
        attributes.merge(documents: Document.where(id: document_ids))
      end

      def render_move(move, status)
        render json: move, status: status, include: MoveSerializer::INCLUDED_ATTRIBUTES, fields: MoveSerializer::INCLUDED_FIELDS
      end

      def move
        @move ||= Move
          .accessible_by(current_ability)
          .includes(:from_location, :to_location, profile: %i[gender ethnicity])
          .find(params[:id])
      end
    end
  end
end
