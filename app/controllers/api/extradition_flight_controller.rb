module Api
  class ExtraditionFlightController < ApiController
    before_action :set_extradition_flight, only: %i[index update]

    PERMITTED_NEW_PARAMS = [
      :type,
      {
        attributes: %i[flight_number flight_time],
        relationships: [{ move: {} }],
      },
    ].freeze

    PERMITTED_UPDATE_PARAMS = [:type, { attributes: %i[flight_number flight_time] }].freeze

    def index
      render_extradition_flight(@extradition_flight, :ok)
    end

    def create
      @extradition_flight = ExtraditionFlight.create!(new_extradtion_flight_attributes)

      render_extradition_flight(@extradition_flight, :created)
    end

    def update
      @extradition_flight.update!(update_extradition_flight_attributes)

      render_extradition_flight(@extradition_flight, :ok)
    end

  private

    def set_extradition_flight
      @extradition_flight = ExtraditionFlight.find_by!(move:)
    end

    def new_extradition_flight_params
      params.require(:data).permit(PERMITTED_NEW_PARAMS)
    end

    def new_extradition_flight_attributes
      @new_extradition_flight_attributes ||= new_extradition_flight_params.to_h[:attributes].merge!(move:)
    end

    def update_extradition_flight_params
      params.require(:data).permit(PERMITTED_UPDATE_PARAMS)
    end

    def update_extradition_flight_attributes
      @update_extradition_flight_attributes ||= update_extradition_flight_params.to_h[:attributes]
    end

    def move
      @move ||= Move.accessible_by(current_ability).find(params.require(:move_id))
    end

    def render_extradition_flight(extradition_flight, status)
      render_json extradition_flight, serializer: ExtraditionFlightSerializer, include: included_relationships, status:
    end
  end
end
