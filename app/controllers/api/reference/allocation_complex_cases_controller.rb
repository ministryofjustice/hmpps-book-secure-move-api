# frozen_string_literal: true

module Api
  module Reference
    class AllocationComplexCasesController < ApiController
      def index
        complex_cases = AllocationComplexCase.all
        render_json complex_cases, serializer: AllocationComplexCaseSerializer
      end
    end
  end
end
