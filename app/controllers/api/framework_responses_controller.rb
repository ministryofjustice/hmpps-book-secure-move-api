# frozen_string_literal: true

module Api
  class FrameworkResponsesController < ApiController
    PPERMITTED_PARAMS = [
      :type,
      attributes: [:value, { value: %i[option details] }, { value: [] }],
    ].freeze

    def update
      framework_response.update!(update_attributes)

      render json: framework_response, status: :ok, include: included_relationships
    end

  private

    def update_params
      params.require(:data).permit(PPERMITTED_PARAMS)
    end

    def update_attributes
      update_params.to_h[:attributes]
    end

    def supported_relationships
      FrameworkResponseSerializer::SUPPORTED_RELATIONSHIPS
    end

    def framework_response
      @framework_response ||= FrameworkResponse.find(params[:id])
    end
  end
end
