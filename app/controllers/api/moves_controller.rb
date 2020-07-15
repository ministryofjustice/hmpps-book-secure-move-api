# frozen_string_literal: true

module Api
  class MovesController < ApiController
    before_action :validate_filter_params, only: %i[index]

    def index
      index_and_render
    end

    def show
      show_and_render
    end

    def create
      create_and_render
    end

    def update
      update_and_render
    end

    def validate_filter_params
      Moves::ParamsValidator.new(filter_params, params[:sort] || {}).validate!(action_name.to_sym)
    end

    PERMITTED_FILTER_PARAMS = %i[
      date_from date_to created_at_from created_at_to location_type status from_location_id to_location_id supplier_id move_type cancellation_reason has_relationship_to_allocation supplier_id
    ].freeze

    def filter_params
      params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
    end
  end
end
