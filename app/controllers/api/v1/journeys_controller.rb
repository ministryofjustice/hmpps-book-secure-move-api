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
                       new_journey
                     else
                       find_journey
                     end
      end

      def new_journey
        Journey.new(new_journey_attributes)
      end

      def find_journey
        move.journeys.find(params.require(:id)).tap do |journey|
          raise CanCan::AccessDenied.new('Not authorized', :manage, Journey) unless current_ability.can?(:manage, journey)
        end
      end

      def validate_params
        Journeys::ParamsValidator.new(data_params).validate!(action_name.to_sym)
      end

      def data_params
        @data_params ||= params.require(:data)
      end

      def new_journey_params
        @new_journey_params ||= data_params.permit(PERMITTED_NEW_JOURNEY_PARAMS).to_h
      end

      def new_journey_attributes
        # NB: we are calling dup() to avoid mutating the underlying params object
        @new_journey_attributes ||= new_journey_params[:attributes].dup.tap do |attribs|
          attribs.merge!(
            move: move,
            supplier: current_user.owner, # NB: using the logged in account as the supplier
            client_timestamp: Time.zone.parse(attribs.delete(:timestamp)),
            from_location: find_location(new_journey_params.dig(:relationships, :from_location, :data, :id)),
            to_location: find_location(new_journey_params.dig(:relationships, :to_location, :data, :id)),
          )
        end
      end

      def find_location(location_id)
        # Finds the referenced location or throws an ActiveModel::ValidationError (which will render as 422 Unprocessable Entity)
        location = Location.find_or_initialize_by(id: location_id)
        unless location.persisted?
          location.errors.add(:location, "reference was not found id=#{location_id}")
          raise ActiveModel::ValidationError.new(location)
        end
        location
      end

      def update_journey_params
        @update_journey_params ||= data_params.permit(PERMITTED_UPDATE_JOURNEY_PARAMS).to_h
      end

      def update_journey_attributes
        # NB: we are calling dup() to avoid mutating the underlying params object
        @update_journey_attributes ||= update_journey_params[:attributes].dup.tap do |attribs|
          attribs.delete(:timestamp) # throw the timestamp away for updates
        end
      end

      def create_event
        # Logs the event for posterity and the immutable event log
        Event.create!(
          event_name: action_name,
          eventable: journey,
          client_timestamp: Time.zone.parse(params.dig(:data, :attributes, :timestamp)),
          details: { data: data_params, supplier_id: current_user.owner.id },
        )
      end
    end
  end
end
