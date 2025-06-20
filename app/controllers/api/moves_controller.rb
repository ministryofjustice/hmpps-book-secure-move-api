# frozen_string_literal: true

module Api
  class MovesController < ApiController
    include Eventable
    include Idempotentable

    before_action :validate_filter_params, only: %i[index filtered]
    before_action :validate_idempotency_key, only: %i[create update]
    around_action :idempotent_action, only: %i[create update]

    CSV_INCLUDES = [:from_location, :to_location, :journeys, :profile, :supplier, { person: %i[gender ethnicity] }].freeze
    STREAM_CSV_MOVES_THRESHOLD = ENV.fetch('MOVES_CSV_ASYNC_THRESHOLD', 5000).to_i

    def index
      index_and_render
    end

    def csv
      csv_moves = find_moves(active_record_relationships: CSV_INCLUDES)
      if (params[:async] == 'allow') && csv_moves.size > STREAM_CSV_MOVES_THRESHOLD

        recipient_email = ManageUsersApiClient::UserEmail.get(created_by)
        if recipient_email
          MovesExportEmailWorker.perform_async(
            recipient_email,
            csv_moves.pluck(:id),
          )
          render json: {
            success: true,
            message: 'Your CSV export is being prepared and will be emailed to you shortly',
          }, status: :accepted and return
        end
      end

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
        filter_params:,
        ability: current_ability,
        order_params: params[:sort] || {},
        active_record_relationships:,
      ).call
    end

    def moves
      @moves ||= find_moves(active_record_relationships:)
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
      person_id
      reference
      recall_date
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
