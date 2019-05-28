# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApiController
      def index
        moves = Moves::Finder.new(filter_params).call

        paginate moves, include: {
          person: %i[first_names last_name date_of_birth ethnicity gender],
          from_location: %i[location_type description],
          to_location: %i[location_type description]
        }
      end

      def show
        move = Move.find(params[:id])

        render_move(move, 200)
      end

      private

      PERMITTED_FILTER_PARAMS = %i[date_from date_to from_location_id location_type status].freeze

      def filter_params
        params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
      end

      def render_move(move, status)
        render json: move, status: status, include: {
          person: %i[first_names last_name date_of_birth],
          from_location: %i[location_type description],
          to_location: %i[location_type description]
        }
      end
    end
  end
end
