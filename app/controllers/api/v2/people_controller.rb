# frozen_string_literal: true

module Api
  module V2
    class PeopleController < ApiController
      def index
        # people = People::Finder.new(filter_params).call
        people = Person.where(filter_params)

        paginate people, include: included_relationships, each_serializer: ::V2::PersonSerializer
      end

    private

      PERMITTED_FILTER_PARAMS = %i[police_national_computer criminal_records_office prison_number].freeze

      def filter_params
        params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
      end

      def included_relationships
        IncludeParamHandler.new(params).call
      end
    end
  end
end
