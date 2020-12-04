# frozen_string_literal: true

module Api
  module Reference
    class IdentifierTypesController < ApiController
      def index
        identifier_types = IdentifierType.all
        render_json identifier_types, serializer: IdentifierTypeSerializer
      end
    end
  end
end
