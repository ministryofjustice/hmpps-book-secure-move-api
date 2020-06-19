# frozen_string_literal: true

module Api
  module V1
    class PeopleController < ApiController
      before_action :validate_timetable_filter_params, only: [:timetable]
      before_action :validate_nomis_profile, only: %i[court_cases image timetable]

      def index
        index_and_render
      end

      def create
        create_and_render
      end

      def update
        update_and_render
      end

      def image
        success = People::RetrieveImage.call(person)

        if success
          render json: Image.new(person.id, url_for(person.image))
        else
          raise ActiveRecord::RecordNotFound, 'Image not found'
        end
      end

      def court_cases
        response = People::RetrieveCourtCases.call(person, court_case_filter_params)

        if response.success?
          render json: response.court_cases, each_serializer: CourtCaseSerializer, include: :location
        else
          render json: json_api_errors_for(response.error)
        end
      end

      def timetable
        start_date = Date.parse(timetable_filter_params[:date_from])
        end_date = Date.parse(timetable_filter_params[:date_to])

        response = People::RetrieveTimetable.call(person, start_date, end_date)

        if response.success?
          render json: response.content, each_serializer: TimetableSerializer, include: :location
        else
          render json: json_api_errors_for(response.error)
        end
      end

    private

      def json_api_errors_for(error)
        { errors: [error.json_api_error] }
      end

      PERMITTED_COURT_CASE_FILTER_PARAMS = %i[active].freeze
      PERMITTED_TIMETABLE_FILTER_PARAMS = %i[date_from date_to].freeze
      def person
        @person ||= Person.find(params[:person_id] || params[:id])
      end

      def court_case_filter_params
        return unless params[:filter]

        params.require(:filter).permit(PERMITTED_COURT_CASE_FILTER_PARAMS).to_h
      end

      def timetable_filter_params
        params.require(:filter).permit(PERMITTED_TIMETABLE_FILTER_PARAMS).to_h
      end

      def validate_timetable_filter_params
        People::ParamsValidator.new(timetable_filter_params).tap do |validator|
          if validator.invalid?
            render status: :bad_request,
                   json: {
                     errors: validator.errors.map { |field, message| { title: field, detail: message } },
                   }
          end
        end
      end

      def validate_nomis_profile
        profile_validator = People::NomisPersonValidator.new(person)
        profile_validator.validate!
      end
    end
  end
end
