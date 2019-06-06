# frozen_string_literal: true

module Api
  module V1
    class PeopleController < ApiController
      def create
        person = People::Creator.new(person_params).call
        render_person(person, 201)
      end

      private

      # TODO: Complete the list of attributes and relationships
      PERSON_ATTRIBUTES = [:first_names, :last_name, :date_of_birth].freeze
      PERMITTED_PERSON_PARAMS = [:type, attributes: PERSON_ATTRIBUTES, relationships: {}].freeze

      def render_person(person, status)
        render json: person, status: status
      end

      def person_params
        params.require(:data).permit(PERMITTED_PERSON_PARAMS).to_h
      end
    end
  end
end
