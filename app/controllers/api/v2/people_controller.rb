# frozen_string_literal: true

module Api
  module V2
    class PeopleController < ApiController
      def index
        # people = People::Finder.new(filter_params).call

        people = if filter_params.any?
                   Person.where(filter_params)
                 else
                   Person.all
                 end
        paginate people, include: PersonSerializer::INCLUDED_DETAIL
      end

    private

      PERMITTED_FILTER_PARAMS = %i[police_national_computer criminal_records_office prison_number].freeze

      def filter_params
        params.permit(:filter).permit(PERMITTED_FILTER_PARAMS).to_h
      end
    end
  end
end
