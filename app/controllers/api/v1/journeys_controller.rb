# frozen_string_literal: true

module Api
  module V1
    class JourneysController < ApiController
      before_action :validate_params, only: %i[create update]
      after_action :create_event, only: %i[create update]

      PERMITTED_NEW_JOURNEY_PARAMS = [
          :type,
          attributes: [:timestamp, :billable, vehicle: {}],
          relationships: [from_location: {}, to_location: {}],
      ].freeze

      PERMITTED_UPDATE_JOURNEY_PARAMS = [
          :type,
          attributes: [:timestamp, :billable, vehicle: {}],
      ].freeze

      def index
        paginate journeys
      end

      def show
        render json: journey, status: :ok
      end

      def create
        authorize!(:create, journey)
        journey.save!
        render json: journey, status: :created
      end

      def update
        journey.update!(update_journey_attributes)
        render json: journey, status: :ok
      end

    private

      def move
        @move ||= Move.accessible_by(current_ability).find(params.require(:move_id))
      end

      def journeys
        @journeys ||= move.journeys.accessible_by(current_ability).default_order
      end

      def journey
        @journey ||= if action_name == 'create'
                       Journey.new(new_journey_attributes)
                     else
                       journeys.find(params.require(:id))
                     end
      end

      def validate_params
        Journeys::ParamsValidator.new(params, action_name).validate!
      end

      def new_journey_params
        @new_journey_params ||= params.require(:data).permit(PERMITTED_NEW_JOURNEY_PARAMS).to_h
      end

      def new_journey_attributes
        # NB: we are calling dup() to avoid mutating the underlying params object
        @new_journey_attributes ||= new_journey_params[:attributes].dup.tap do |attribs|
          attribs.merge!(
            move: move,
            supplier: current_user&.owner,
            details: { metadata: { vehicle: attribs.delete(:vehicle) } },
            client_timestamp: Time.zone.parse(attribs.delete(:timestamp)),
            from_location: Location.find(new_journey_params.dig(:relationships, :from_location, :data, :id)),
            to_location: Location.find(new_journey_params.dig(:relationships, :to_location, :data, :id)),
          )
        end
      end

      def update_journey_params
        @update_journey_params ||= params.require(:data).permit(PERMITTED_UPDATE_JOURNEY_PARAMS).to_h
      end

      def update_journey_attributes
        # NB: we are calling dup() to avoid mutating the underlying params object
        @update_journey_attributes ||= update_journey_params[:attributes].dup.tap do |attribs|
          attribs[:details] = { metadata: { vehicle: attribs.delete(:vehicle) } } if attribs[:vehicle].present?

          attribs.delete(:timestamp) # throw the timestamp away for updates
        end
      end

      def create_event
        puts "IN CREATE EVENT: #{journey} (#{action_name})"
      end
    end
  end
end
