# frozen_string_literal: true

module Api
  module V1
    class JourneysController < ApiController
      def index
        paginate journeys
      end

      def show
        render json: journey, status: :ok
      end

      def create; end

      def update; end

    private

      def move
        @move ||= Move.accessible_by(current_ability).find(params.require(:move_id))
      end

      def journeys
        @journeys ||= move.journeys.accessible_by(current_ability).default_order
      end

      def journey
        @journey ||= journeys.find(params.require(:id))
      end
    end
  end
end
