# frozen_string_literal: true

module Api
  module V1
    class PeopleController < ApiController
      def create
        creator.call
        render_person(creator.person, 201)
      end

      private

      # TODO: Complete the list of attributes and relationships
      PERSON_ATTRIBUTES = %i[first_names last_name date_of_birth].freeze
      PERMITTED_PERSON_PARAMS = [:type, attributes: PERSON_ATTRIBUTES, relationships: {}].freeze

      def creator
        @creator ||= People::Creator.new(person_params)
      end

      def render_person(person, status)
        render json: person, status: status
      end

      def person_params
        params.require(:data).permit(PERMITTED_PERSON_PARAMS).to_h
      end
    end
  end
end
