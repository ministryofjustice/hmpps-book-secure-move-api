# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApiController
      before_action :validate_filter_params, only: %i[index]

      def index
        moves = Moves::Finder.new(filter_params, current_ability, params[:sort] || {}).call
        # Excludes potentially many court hearing documents to reduce the request size. This was requested specifically by the frontend team.
        paginate moves, include: MoveSerializer::INCLUDED_ATTRIBUTES.dup.except(:court_hearings), fields: MoveSerializer::INCLUDED_FIELDS
      end

      def show
        render_move(move, :ok)
      end

      def create
        move = Move.new(new_move_attributes)
        authorize!(:create, move)
        move.save!

        Notifier.prepare_notifications(topic: move, action_name: 'create')

        render_move(move, :created)
      end

      def update
        raise ActiveRecord::ReadOnlyRecord, 'Can\'t change moves coming from Nomis' if move.from_nomis?

        updater.call

        Notifier.prepare_notifications(topic: updater.move, action_name: updater.status_changed ? 'update_status' : 'update')
        render_move(updater.move, :ok)
      end

      def destroy
        # TODO: raise ActiveRecord::ReadOnlyRecord.new('Move cannot be deleted')

        move.destroy!
        Notifier.prepare_notifications(topic: move, action_name: 'destroy')
        render_move(move, 200)
      end

    private

      PERMITTED_FILTER_PARAMS = %i[
        date_from date_to created_at_from created_at_to location_type status from_location_id to_location_id supplier_id move_type cancellation_reason
      ].freeze
      PERMITTED_NEW_MOVE_PARAMS = [
        :type,
        attributes: %i[date time_due status move_type additional_information
                       cancellation_reason cancellation_reason_comment
                       reason_comment move_agreed move_agreed_by date_from date_to],
        relationships: {},
      ].freeze
      PERMITTED_UPDATE_MOVE_PARAMS = [
        :type,
        attributes: %i[date time_due status additional_information
                       cancellation_reason cancellation_reason_comment
                       reason_comment move_agreed move_agreed_by date_from date_to],
        relationships: {},
      ].freeze

      def filter_params
        params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
      end

      def validate_filter_params
        Moves::ParamsValidator.new(filter_params, params[:sort] || {}).validate!(action_name.to_sym)
      end

      def new_move_params
        params.require(:data).permit(PERMITTED_NEW_MOVE_PARAMS).to_h
      end

      def new_move_attributes
        # moves are always created against the latest_profile for the person
        new_move_params[:attributes].merge(
          person: Person.find(new_move_params.dig(:relationships, :person, :data, :id)),
          from_location: Location.find(new_move_params.dig(:relationships, :from_location, :data, :id)),
          to_location: Location.find_by(id: new_move_params.dig(:relationships, :to_location, :data, :id)),
          documents: Document.where(id: (new_move_params.dig(:relationships, :documents, :data) || []).map { |doc| doc[:id] }),
          court_hearings: CourtHearing.where(id: (new_move_params.dig(:relationships, :court_hearings, :data) || []).map { |court_hearing| court_hearing[:id] }),
          prison_transfer_reason: PrisonTransferReason.find_by(id: new_move_params.dig(:relationships, :prison_transfer_reason, :data, :id)),
        )
      end

      def update_move_params
        params.require(:data).permit(PERMITTED_UPDATE_MOVE_PARAMS).to_h
      end

      def render_move(move, status)
        render json: move, status: status, include: MoveSerializer::INCLUDED_ATTRIBUTES, fields: MoveSerializer::INCLUDED_FIELDS
      end

      def move
        @move ||= Move
          .accessible_by(current_ability)
          .includes(:from_location, :to_location, person: { profiles: %i[gender ethnicity] })
          .find(params[:id])
      end

      def updater
        @updater ||= Moves::Updater.new(move, update_move_params)
      end
    end
  end
end
