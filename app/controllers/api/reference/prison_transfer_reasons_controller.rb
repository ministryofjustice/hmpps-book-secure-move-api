# frozen_string_literal: true

module Api
  module Reference
    class PrisonTransferReasonsController < ApiController
      def index
        reasons = PrisonTransferReason.all
        render json: reasons
      end
    end
  end
end
