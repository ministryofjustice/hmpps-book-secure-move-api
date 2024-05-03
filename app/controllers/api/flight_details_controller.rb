module Api
  class FlightDetailsController < ApiController
    before_action :set_flight_details, only: %i[index update]

    PERMITTED_NEW_PARAMS = [
      :type,
      {
        attributes: %i[flight_number flight_time],
        relationships: [{ move: {} }],
      },
    ].freeze

    PERMITTED_UPDATE_PARAMS = [:type, { attributes: %i[flight_number flight_time] }].freeze

    def index
      render_flight_details(@flight_details, :ok)
    end

    def create
      @flight_details = FlightDetails.new(new_flight_details_attributes)

      @flight_details.save!

      render_flight_details(@flight_details, :created)
    end

    def update
      @flight_details.update!(update_flight_details_attributes)

      render_flight_details(@flight_details, :ok)
    end

  private

    def set_flight_details
      @flight_details = FlightDetails.find_by!(move:)
    end

    def new_flight_details_params
      params.require(:data).permit(PERMITTED_NEW_PARAMS)
    end

    def new_flight_details_attributes
      @new_flight_details_attributes ||= new_flight_details_params.to_h[:attributes].merge!(move:)
    end

    def update_flight_details_params
      params.require(:data).permit(PERMITTED_UPDATE_PARAMS)
    end

    def update_flight_details_attributes
      @update_flight_details_attributes ||= update_flight_details_params.to_h[:attributes]
    end

    def move
      @move ||= Move.accessible_by(current_ability).find(params.require(:move_id))
    end

    def render_flight_details(flight_details, status)
      render_json flight_details, serializer: FlightDetailsSerializer, include: included_relationships, status:
    end
  end
end
