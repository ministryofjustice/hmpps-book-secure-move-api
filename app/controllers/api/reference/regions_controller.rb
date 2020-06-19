# frozen_string_literal: true

module Api
  module Reference
    class RegionsController < ApiController
      def index
        render json: Region.all.includes(:locations)
      end
    end
  end
end
