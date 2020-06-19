# frozen_string_literal: true

module Api
  module V1
    module Reference
      class AllocationComplexCasesController < ApiController
        def index
          render json: AllocationComplexCase.all
        end
      end
    end
  end
end
