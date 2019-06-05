# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApiController
      def index
        moves = Moves::Finder.new(filter_params).call
        paginate moves, include: MoveSerializer::INCLUDED_OVERVIEW
      end

      def show
        move = find_move
        render_move(move, 200)
      end

      private

      PERMITTED_FILTER_PARAMS = %i[date_from date_to from_location_id location_type status].freeze

      def filter_params
        params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
      end

      def render_move(move, status)
        render json: move, status: status, include: MoveSerializer::INCLUDED_DETAIL
      end

      def find_move
        Move
          .includes(:from_location, :to_location, person: { profiles: %i[gender ethnicity] })
          .find(params[:id])
      end
    end
  end
end
