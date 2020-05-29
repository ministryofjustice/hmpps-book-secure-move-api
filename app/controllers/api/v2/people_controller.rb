# frozen_string_literal: true

module Api
  module V2
    class PeopleController < ApiController
      def index
        # people = People::Finder.new(filter_params).call
        people = Person.all

        paginate people, include: PersonSerializer::INCLUDED_DETAIL
      end

    private

      PERMITTED_FILTER_PARAMS = %i[police_national_computer criminal_records_office prison_number].freeze

      def filter_params
        params.require(:filter).permit(PERMITTED_FILTER_PARAMS).to_h
      end
    end
  end
end
