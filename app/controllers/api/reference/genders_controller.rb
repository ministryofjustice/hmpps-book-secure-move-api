# frozen_string_literal: true

module Api
  module Reference
    class GendersController < ApiController
      def index
        genders = Gender.all
        render_json genders, serializer: GenderSerializer
      end
    end
  end
end
