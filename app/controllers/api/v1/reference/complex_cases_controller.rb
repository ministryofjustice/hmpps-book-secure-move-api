# frozen_string_literal: true

module Api
  module V1
    module Reference
      class ComplexCasesController < ApiController
        def index
          render json: ComplexCase.all
        end
      end
    end
  end
end
