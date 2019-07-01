# frozen_string_literal: true

module Api
  module V1
    module Reference
      class IdentifierTypesController < ApiController
        def index
          genders = Gender.all
          render json: genders
        end

        private

      end
    end
  end
end
