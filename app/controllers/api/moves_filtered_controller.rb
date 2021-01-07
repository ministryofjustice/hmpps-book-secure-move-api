# frozen_string_literal: true

module Api
  class MovesFilteredController < MovesController
  private

    PERMITTED_CREATE_FILTER_PARAMS = [
      :type,
      attributes: [filter: PERMITTED_FILTER_PARAMS],
    ].freeze

    def create_filter_params
      @create_filter_params ||= params.require(:data).permit(PERMITTED_CREATE_FILTER_PARAMS).to_h
    end

    def filter_params
      @filter_params ||= create_filter_params.dig(:attributes, :filter) || {}
    end
  end
end
