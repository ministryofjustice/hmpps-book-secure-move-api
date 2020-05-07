# frozen_string_literal: true

module Api
  module V1
    class JourneysController < ApiController
      before_action :validate_params, only: %i[create update]

      PERMITTED_JOURNEY_PARAMS = [
          :type,
          attributes: [:timestamp, :billable, vehicle: {}],
          relationships: [from_location: {}, to_location: {}],
      ].freeze

      def index
        paginate journeys
      end

      def show
        render json: journey, status: :ok
      end

      def create
        journey = Journey.new(journey_attributes)
        authorize!(:create, journey)
        journey.save!
        render json: journey, status: :created
      end

      def update
        # TODO: coming soon
      end

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

      def validate_params
        Journeys::ParamsValidator.new(journey_params, action_name).validate!
      end

      def journey_params
        @journey_params ||= params.require(:data).permit(PERMITTED_JOURNEY_PARAMS).to_h
      end

      def journey_attributes
        # NB: it is important to do .tap after the .merge to avoid modifying params
        @journey_attributes ||= journey_params[:attributes]
          .merge(
            move: move,
            supplier: current_user&.owner,
            from_location: Location.find(journey_params.dig(:relationships, :from_location, :data, :id)),
            to_location: Location.find(journey_params.dig(:relationships, :to_location, :data, :id)),
            )
          .then { |attribs| # NB: we avoid mutating the original params by calling delete() after merge()
            attribs.merge(
              client_timestamp: Time.zone.parse(attribs.delete(:timestamp)),
              details: { metadata: { vehicle: attribs.delete(:vehicle) } },
            )
          }
      end
    end
  end
end
