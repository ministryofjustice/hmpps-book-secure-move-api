# frozen_string_literal: true

module Api
  module V1
    module Reference
      class GendersController < ApiController
        def index
          genders = Gender.all
          render json: genders
        end
      end
    end
  end
end
