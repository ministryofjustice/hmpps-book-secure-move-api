# frozen_string_literal: true

module Api
  module V1
    class AllocationsController < ApiController
      def index
        allocations_params = Allocations::ParamsValidator.new(filter_params)
        if allocations_params.valid?
          allocations = Allocations::Finder.new(filter_params).call
          paginate allocations, include: AllocationSerializer::INCLUDED_ATTRIBUTES
        else
          render_allocation({ error: allocations_params.errors }, :bad_request)
        end
      end

      def create
        allocation = Allocation.new(allocation_attributes)
        allocation.save!

        render_allocation(allocation, 201)
      end

      def show
        allocation = find_allocation

        render_allocation(allocation, :ok)
      end

    private

      PERMITTED_FILTER_PARAMS = %i[date_from date_to locations from_locations to_locations].freeze

      PERMITTED_ALLOCATION_PARAMS = [
        :type,
        attributes: %i[date prisoner_category sentence_length moves_count complete_in_full other_criteria],
        relationships: {},
      ].freeze

      PERMITTED_COMPLEX_CASE_PARAMS = %i[key title answer allocation_complex_case_id].freeze

      def filter_params
        params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
      end

      def allocation_params
        params.require(:data).permit(PERMITTED_ALLOCATION_PARAMS).to_h
      end

      def complex_case_params
        params.require(:data).require(:attributes).permit(complex_cases: PERMITTED_COMPLEX_CASE_PARAMS)[:complex_cases]&.map(&:to_h)
      end

      def allocation_attributes
        allocation_params[:attributes].merge(
          from_location: Location.find(allocation_params.dig(:relationships, :from_location, :data, :id)),
          to_location: Location.find(allocation_params.dig(:relationships, :to_location, :data, :id)),
          complex_cases: Allocation::ComplexCaseAnswers.new(complex_case_params),
        )
      end

      def render_allocation(allocation, status)
        render json: allocation, status: status, include: AllocationSerializer::INCLUDED_ATTRIBUTES
      end

      def find_allocation
        Allocation.find(params[:id])
      end
    end
  end
end
