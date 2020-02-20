# frozen_string_literal: true

module Api
  module V1
    module Reference
      class ReasonsController < ApiController
        def index
          reasons = Reason.all
          puts reasons.inspect
          render json: reasons
        end
      end
    end
  end
end
