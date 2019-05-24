# frozen_string_literal: true

module Api
  module V1
    module Reference
      class EthnicitiesController < ApiController
        def index
          ethnicities = Ethnicity.all
          render json: ethnicities
        end
      end
    end
  end
end
