# frozen_string_literal: true

module Api
  module Reference
    class PrisonTransferReasonsController < ApiController
      def index
        reasons = PrisonTransferReason.all
        render_json reasons, serializer: PrisonTransferReasonSerializer
      end
    end
  end
end
