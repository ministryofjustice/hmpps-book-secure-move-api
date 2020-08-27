# frozen_string_literal: true

module Api
  class AllocationsController < ApiController
    after_action :send_move_notifications, only: :create

    def index
      allocations_params = Allocations::ParamsValidator.new(filter_params, sort_params)
      if allocations_params.valid?
        allocations = Allocations::Finder.new(filters: filter_params, ordering: sort_params, search: search_params).call
        paginate allocations, include: included_relationships
      else
        render_allocation({ error: allocations_params.errors }, :bad_request)
      end
    end

    def create
      creator.call

      render_allocation(creator.allocation, 201)
    end

    def show
      allocation = find_allocation

      render_allocation(allocation, :ok)
    end

  private

    PERMITTED_FILTER_PARAMS = %i[date_from date_to locations from_locations to_locations status].freeze
    PERMITTED_SORT_PARAMS = %i[by direction].freeze
    PERMITTED_SEARCH_PARAMS = %i[location person].freeze

    PERMITTED_ALLOCATION_PARAMS = [
      :type,
      attributes: %i[date estate estate_comment prisoner_category sentence_length sentence_length_comment moves_count complete_in_full other_criteria requested_by],
      relationships: {},
    ].freeze

    PERMITTED_COMPLEX_CASE_PARAMS = %i[key title answer allocation_complex_case_id].freeze

    def sort_params
      @sort_params ||= params.fetch(:sort, {}).permit(PERMITTED_SORT_PARAMS).to_h
    end

    def filter_params
      @filter_params ||= params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
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
      render json: allocation, status: status, include: included_relationships
    end

    def find_allocation
      Allocation.find(params[:id])
    end

    def creator
      @creator ||= Allocations::Creator.new(
        allocation_params: allocation_params,
        complex_case_params: complex_case_params,
        doorkeeper_application_owner: doorkeeper_application_owner,
      )
    end

    def send_move_notifications
      creator.allocation.moves.each do |move|
        Notifier.prepare_notifications(topic: move, action_name: 'create')
      end
    end

    def supported_relationships
      AllocationSerializer::SUPPORTED_RELATIONSHIPS
    end
  end
end
