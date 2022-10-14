# frozen_string_literal: true

module Api
  class AllocationsController < ApiController
    after_action :send_move_notifications, only: :create

    def index
      index_and_render
    end

    def create
      creator.call

      render_allocation(creator.allocation, 201)
    end

    def update
      update_and_render
    end

    def show
      render_allocation(allocation, :ok)
    end

    def filtered
      index_and_render
    end

    private

    PERMITTED_FILTER_PARAMS = %i[date_from date_to locations from_locations to_locations status].freeze
    PERMITTED_SORT_PARAMS = %i[by direction].freeze
    PERMITTED_SEARCH_PARAMS = %i[location person].freeze

    PERMITTED_ALLOCATION_PARAMS = [
      :type,
      { attributes: %i[date estate estate_comment prisoner_category sentence_length sentence_length_comment moves_count complete_in_full other_criteria requested_by],
        relationships: {} },
    ].freeze

    PERMITTED_UPDATE_PARAMS = [
      { attributes: %i[date] },
    ].freeze

    PERMITTED_COMPLEX_CASE_PARAMS = %i[key title answer allocation_complex_case_id].freeze

    PERMITTED_FILTERED_PARAMS = [
      :type,
      { attributes: [filter: PERMITTED_FILTER_PARAMS] },
    ].freeze

    def sort_params
      @sort_params ||= params.fetch(:sort, {}).permit(PERMITTED_SORT_PARAMS).to_h
    end

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

    def search_params
      params.fetch(:search, {}).permit(PERMITTED_SEARCH_PARAMS).to_h
    end

    def allocation_params
      params.require(:data).permit(PERMITTED_ALLOCATION_PARAMS).to_h
    end

    def complex_case_params
      params.require(:data).require(:attributes).permit(complex_cases: PERMITTED_COMPLEX_CASE_PARAMS)[:complex_cases]&.map(&:to_h)
    end

    def render_allocation(allocation, status)
      render_json allocation, serializer: AllocationSerializer, include: included_relationships, status: status
    end

    def allocations
      Allocations::Finder.new(
        filters: filter_params,
        ordering: sort_params,
        search: search_params,
        active_record_relationships: active_record_relationships,
      ).call
    end

    def creator
      @creator ||= Allocations::Creator.new(
        doorkeeper_application_owner: doorkeeper_application_owner,
        allocation_params: allocation_params,
        complex_case_params: complex_case_params,
      )
    end

    def send_move_notifications
      creator.allocation.moves.each do |move|
        Notifier.prepare_notifications(topic: move, action_name: 'create')
      end
    end

    def supported_relationships
      # for performance reasons, we support fewer include relationships on the index action
      if action_name == 'index'
        AllocationsSerializer::SUPPORTED_RELATIONSHIPS
      else
        AllocationSerializer::SUPPORTED_RELATIONSHIPS
      end
    end

    def index_and_render
      allocations_params = Allocations::ParamsValidator.new(filter_params, sort_params)
      if allocations_params.valid?
        paginate allocations, serializer: AllocationsSerializer, include: included_relationships, fields: AllocationsSerializer::INCLUDED_FIELDS do |paginated_allocations, options|
          options[:params] = { totals: paginated_allocations.move_totals }
        end
      else
        render json: { error: allocations_params.errors }, status: :bad_request
      end
    end

    def allocation
      @allocation ||= Allocation
                        .accessible_by(current_ability)
                        .includes(active_record_relationships)
                        .find(params[:id])
    end

    def update_and_render
      # COPIED FROM ELSEWHERE
      #
      # allocation.assign_attributes(update_params)
      # action_name = move.status_changed? ? 'update_status' : 'update'
      # move_date_changed = move.date_changed?
      # move.save!
      #
      # create_automatic_event!(eventable: move, event_class: GenericEvent::MoveDateChanged, details: { date: move.date.iso8601 }) if move_date_changed
      #
      # move.allocation&.refresh_status_and_moves_count!
      #
      # Allocations::CreateInNomis.call(move) if create_in_nomis?
      # Notifier.prepare_notifications(topic: move, action_name: action_name)
      #
      # render_move(move, :ok)
    end

    def update_params
      @move_params ||= params.require(:data).permit(PERMITTED_UPDATE_PARAMS).to_h
    end
  end
end
