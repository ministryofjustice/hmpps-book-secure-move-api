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
          render json: { error: allocations_params.errors }, status: :bad_request
        end
      end

    private

      def filter_params
        params.fetch(:filter, {}).permit(:date_from, :date_to).to_h
      end
    end
  end
end
