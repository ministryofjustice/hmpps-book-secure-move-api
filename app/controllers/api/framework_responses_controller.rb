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

    BULK_PERMITTED_PARAMS = (%i[id] + PERMITTED_PARAMS).freeze

    rescue_from FrameworkResponse::ValueTypeError, with: :render_value_type_error
    rescue_from FrameworkResponses::BulkUpdateError, with: :render_bulk_update_error

    def update
      framework_response.update_with_flags!(
        new_value: update_framework_response_attributes,
        responded_by: created_by,
        responded_at: Time.zone.now.iso8601,
      )

      render_json framework_response, serializer: FrameworkResponseSerializer, include: included_relationships, status: :ok
    end

    def bulk_update
      FrameworkResponses::BulkUpdater.new(
        assessment: assessment,
        response_values_hash: bulk_update_framework_response_values,
        responded_by: created_by,
        responded_at: Time.zone.now.iso8601,
      ).call

      render status: :no_content
    end

  private

    def update_framework_response_params
      params.require(:data).permit(PERMITTED_PARAMS)
    end

    def update_framework_response_attributes
      update_framework_response_params.to_h.dig(:attributes, :value)
    end

    def bulk_update_framework_response_params
      params.require(:data).map { |response| response.permit(BULK_PERMITTED_PARAMS) }
    end

    def bulk_update_framework_response_values
      bulk_update_framework_response_params.each_with_object({}) do |response_params, hash|
        hash[response_params['id']] = response_params.to_h.dig(:attributes, :value)
      end
    end

    def supported_relationships
      FrameworkResponseSerializer::SUPPORTED_RELATIONSHIPS
    end

    def framework_response
      @framework_response ||= FrameworkResponse.find(params[:id])
    end

    def assessment
      @assessment ||= params['assessment_class'].find(params[:id])
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

    def render_bulk_update_error(exception)
      errors = exception.errors.map do |id, error_message|
        {
          id: id,
          title: 'Invalid value',
          detail: error_message,
          source: { pointer: '/data/attributes/value' },
        }
      end

      render(
        json: { errors: errors },
        status: :unprocessable_entity,
      )
    end
  end
end
