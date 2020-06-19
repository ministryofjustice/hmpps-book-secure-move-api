# frozen_string_literal: true

module Api
  module Reference
    class IdentifierTypesController < ApiController
      def index
        identifier_types = IdentifierType.all
        render json: identifier_types
      end
    end
  end
end
