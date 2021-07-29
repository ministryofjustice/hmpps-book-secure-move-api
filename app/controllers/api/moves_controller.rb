# frozen_string_literal: true

module Api
  class MovesController < ApiController
    include Eventable

    before_action :validate_filter_params, only: %i[index filtered]

    CSV_INCLUDES = [:from_location, :to_location, { profile: :documents }, { person: %i[gender ethnicity] }].freeze

    def index
      index_and_render
    end

    def csv
      csv_moves = find_moves(active_record_relationships: CSV_INCLUDES)
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

    def filtered
      index_and_render
    end

  private

    def find_moves(active_record_relationships:)
      Moves::Finder.new(
        filter_params: filter_params,
        ability: current_ability,
        order_params: params[:sort] || {},
        active_record_relationships: active_record_relationships,
      ).call
    end

    def moves
      @moves ||= find_moves(active_record_relationships: active_record_relationships)
    end

    def validate_filter_params
      Moves::ParamsValidator.new(filter_params, params[:sort] || {}).validate!(action_name.to_sym)
    end

    PERMITTED_FILTER_PARAMS = %i[
      date_from
      date_to
      created_at_from
      created_at_to
      date_of_birth_from
      date_of_birth_to
      location_type
      status
      from_location_id
      to_location_id
      location_id
      supplier_id
      move_type
      cancellation_reason
      rejection_reason
      has_relationship_to_allocation
      ready_for_transit
      profile_id
    ].freeze

    PERMITTED_FILTERED_PARAMS = [
      :type,
      { attributes: [filter: PERMITTED_FILTER_PARAMS] },
    ].freeze

    def filtered_params
      @filtered_params ||= params.require(:data).permit(PERMITTED_FILTERED_PARAMS).to_h
    end

    def filter_params
      @filter_params ||= if action_name == 'filtered'
                           filtered_params.dig(:attributes, :filter) || {}
                         else
                           params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
                         end
    end
  end
end
