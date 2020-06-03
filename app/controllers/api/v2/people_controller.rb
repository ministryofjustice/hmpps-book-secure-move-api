# frozen_string_literal: true

module Api
  module V2
    class PeopleController < ApiController
      def create
        person = Person.create(person_attributes)

        render json: person, status: :created, include: included_relationships, serializer: ::V2::PersonSerializer
      end

      def index
        people = ::V2::People::Finder.new(filter_params).call

        paginate people, include: included_relationships, each_serializer: ::V2::PersonSerializer
      end

    private

      PERMITTED_FILTER_PARAMS = %i[police_national_computer criminal_records_office prison_number].freeze

      PERSON_ATTRIBUTES = %i[
        first_names
        last_name
        date_of_birth
        prison_number
        criminal_records_office
        police_national_computer
        gender_additional_information
      ].freeze
      PERMITTED_PERSON_PARAMS = [:type, attributes: PERSON_ATTRIBUTES, relationships: {}].freeze

      def filter_params
        params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
      end

      def supported_relationships
        ::V2::PersonSerializer::SUPPORTED_RELATIONSHIPS
      end

      def person_params
        params.require(:data).permit(PERMITTED_PERSON_PARAMS).to_h
      end

      def person_attributes
        person_params[:attributes].merge(
          ethnicity_id: params.require(:data).dig(:relationships, :ethnicity, :data, :id),
          gender_id: params.require(:data).dig(:relationships, :gender, :data, :id),
        )
      end
    end
  end
end
