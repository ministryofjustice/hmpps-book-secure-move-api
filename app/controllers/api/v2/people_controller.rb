# frozen_string_literal: true

module Api
  module V2
    class PeopleController < ApiController
      before_action :validate_include_params, only: :index

      def create
        person = Person.last

        render json: person, status: :created
      end

      def index
        people = ::V2::People::Finder.new(filter_params).call

        paginate people, include: included_relationships, each_serializer: ::V2::PersonSerializer
      end

    private

      PERMITTED_FILTER_PARAMS = %i[police_national_computer criminal_records_office prison_number].freeze

      def filter_params
        params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
      end

      def supported_relationships
        ::V2::PersonSerializer::SUPPORTED_RELATIONSHIPS
      end
    end
  end
end
