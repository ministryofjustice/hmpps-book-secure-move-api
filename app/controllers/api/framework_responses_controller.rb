# frozen_string_literal: true

module Api
  class FrameworkResponsesController < ApiController
    # NB: permit multiple types of value attributes: array, array of objects,
    # object with option details fields, and string
    PERMITTED_PARAMS = [
      :type,
      attributes: [
        :value,
        { value: [:option, :details, :item, responses: [:framework_question_id, :value, { value: %i[option details] }, { value: [] }]] },
        { value: [] },
      ],
    ].freeze

    rescue_from FrameworkResponse::ValueTypeError, with: :render_value_type_error

    def update
      framework_response.update_with_flags!(update_framework_response_attributes)

      render json: framework_response, status: :ok, include: included_relationships
    end

  private

    def update_framework_response_params
      params.require(:data).permit(PERMITTED_PARAMS)
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

    def render_value_type_error(exception)
      render(
        json: { errors: [{
          title: 'Invalid Value type',
          detail: "Value: #{exception.message} is incorrect type",
          source: { pointer: '/data/attributes/value' },
        }] },
        status: :unprocessable_entity,
      )
    end
  end
end
