# frozen_string_literal: true

module Api
  class FrameworkResponsesController < ApiController
    PPERMITTED_PARAMS = [
      :type,
      attributes: [:value, { value: %i[option details] }, { value: [] }],
    ].freeze

    def update
      framework_response.update_with_flags!(update_framework_response_attributes)

      render json: framework_response, status: :ok, include: included_relationships
    end

  private

    def update_framework_response_params
      params.require(:data).permit(PPERMITTED_PARAMS)
    end

    def update_framework_response_attributes
      update_framework_response_params.to_h.dig(:attributes, :value)
    end

    def supported_relationships
      FrameworkResponseSerializer::SUPPORTED_RELATIONSHIPS
    end

    def framework_response
      @framework_response ||= FrameworkResponse.find(params[:id])
    end
  end
end
