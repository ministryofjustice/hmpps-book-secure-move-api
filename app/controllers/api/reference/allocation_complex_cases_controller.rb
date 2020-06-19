# frozen_string_literal: true

module Api
  module Reference
    class AllocationComplexCasesController < ApiController
      def index
        render json: AllocationComplexCase.all
      end
    end
  end
end
