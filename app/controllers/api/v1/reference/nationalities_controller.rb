# frozen_string_literal: true

module Api
  module V1
    module Reference
      class NationalitiesController < ApiController
        def index
          nationalities = Nationality.all
          render json: nationalities
        end
      end
    end
  end
end
