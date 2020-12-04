# frozen_string_literal: true

module Api
  module Reference
    class EthnicitiesController < ApiController
      def index
        ethnicities = Ethnicity.all
        render_json ethnicities, serializer: EthnicitySerializer
      end
    end
  end
end
