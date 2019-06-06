# frozen_string_literal: true

module Api
  module V1
    class PeopleController < ApiController
      def create
        person = People::Creator.new(person_params).call
        render_move(person, 201)
      end

      private

      def render_person(person, status)
        render json: person, status: status, include: PersonSerializer::INCLUDED_DETAIL
      end
    end
  end
end
