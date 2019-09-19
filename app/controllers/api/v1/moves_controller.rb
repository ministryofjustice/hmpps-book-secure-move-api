# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApiController
      def index
        import_moves_from_nomis
        moves = Moves::Finder.new(filter_params).call
        paginate moves, include: MoveSerializer::INCLUDED_ATTRIBUTES
      end

      def show
        move = find_move
        import_moves_from_nomis(move: move)
        render_move(move.reload, 200)
      end

      def create
        move = Move.create!(move_attributes)
        render_move(move, 201)
      end

      def update
        move = find_move
        raise ActiveRecord::ReadOnlyRecord, 'Can\'t change moves coming from Nomis' if move.from_nomis?

        move.update!(patch_move_attributes)
        render_move(move, 200)
      end

      def destroy
        move = find_move
        move.destroy!
        render_move(move, 200)
      end

      private

      PERMITTED_FILTER_PARAMS = %i[date_from date_to from_location_id location_type status].freeze
      PERMITTED_MOVE_PARAMS = [
        :type,
        attributes: %i[date time_due status move_type additional_information
                       cancellation_reason cancellation_reason_comment],
        relationships: {}
      ].freeze
      PERMITTED_PATCH_MOVE_PARAMS = [attributes: %i[date time_due status additional_information
                                                    cancellation_reason cancellation_reason_comment]].freeze

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
        move_params[:attributes].merge(
          person: Person.find(move_params.dig(:relationships, :person, :data, :id)),
          from_location: Location.find(move_params.dig(:relationships, :from_location, :data, :id)),
          to_location: Location.find_by(id: move_params.dig(:relationships, :to_location, :data, :id))
        )
      end

      def patch_move_attributes
        move_params[:attributes]
      end

      def render_move(move, status)
        render json: move, status: status, include: MoveSerializer::INCLUDED_ATTRIBUTES
      end

      def find_move
        Move
          .includes(:from_location, :to_location, person: { profiles: %i[gender ethnicity] })
          .find(params[:id])
      end

      def import_moves_from_nomis(move: nil)
        if move.present?
          Moves::NomisSynchroniser.new(location: move.from_location, date: move.date).call
        else
          Moves::NomisSynchroniser.new(location: from_location, date: date).call
        end
      rescue StandardError => e
        Raven.capture_exception(e)
      end

      def from_location
        return unless filter_params[:from_location_id]

        @from_location ||= Location.find(filter_params[:from_location_id])
      end

      def date
        return unless filter_params[:date_from]

        Date.parse(filter_params[:date_from])
      end
    end
  end
end
