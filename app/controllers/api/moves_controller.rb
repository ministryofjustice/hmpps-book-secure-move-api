# frozen_string_literal: true

module Api
  class MovesController < ApiController
    before_action :validate_filter_params, only: %i[index]

    CSV_INCLUDES = [:from_location, :to_location, { profile: :documents }, person: %i[gender ethnicity]].freeze

    def index
      index_and_render
    end

    def csv
      csv_moves = Moves::Finder.new(filter_params: filter_params,
                                    ability: current_ability,
                                    order_params: params[:sort] || {},
                                    active_record_relationships: CSV_INCLUDES).call
      send_file(Moves::Exporter.new(csv_moves).call, type: 'text/csv', disposition: :inline)
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

  private

    def moves
      @moves ||= Moves::Finder.new(filter_params: filter_params,
                                   ability: current_ability,
                                   order_params: params[:sort] || {},
                                   active_record_relationships: active_record_relationships).call
    end

    def validate_filter_params
      Moves::ParamsValidator.new(filter_params, params[:sort] || {}).validate!(action_name.to_sym)
    end

    PERMITTED_FILTER_PARAMS = %i[
      date_from date_to created_at_from created_at_to date_of_birth_from date_of_birth_to location_type status from_location_id to_location_id location_id supplier_id move_type cancellation_reason rejection_reason has_relationship_to_allocation ready_for_transit
    ].freeze

    def filter_params
      params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
    end
  end
end
