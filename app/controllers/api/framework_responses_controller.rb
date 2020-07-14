# frozen_string_literal: true

module Api
  class FrameworkResponsesController < ApiController
    PPERMITTED_UPDATE_FR_PARAMS = [
      :type,
      attributes: [:value],
    ].freeze

    def update
      framework_response.update!(value: params[:data][:attributes][:value], responded: true)

      render json: framework_response, status: :ok, include: included_relationships
    end

  private

    def update_fr_params
      params.require(:data).permit(PPERMITTED_UPDATE_FR_PARAMS).to_h
    end

    def supported_relationships
      FrameworkResponseSerializer::SUPPORTED_RELATIONSHIPS
    end

    def framework_response
      @framework_response ||= FrameworkResponse.find(params[:id])
    end
  end
end
