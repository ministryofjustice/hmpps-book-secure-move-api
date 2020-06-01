# frozen_string_literal: true

module Api
  module V2
    class PeopleController < ApiController
      before_action :validate_include_params

      def index
        people = ::V2::People::Finder.new(filter_params).call

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

      def validate_include_params
        ::V2::People::IncludeParamsValidator.new(included_relationships).validate!
      end
    end
  end
end
