# frozen_string_literal: true

module Api
  class PeopleController < ApiController
    before_action :validate_timetable_filter_params, only: [:timetable]
    before_action :validate_nomis_profile, only: %i[court_cases timetable]
    before_action :validate_other_include_params, only: %i[court_cases timetable]
    before_action :validate_include_params, except: %i[court_cases timetable]

    def index
      index_and_render
    end

    def show
      show_and_render
    end

    def create
      create_and_render
    end

    def update
      update_and_render
    end

    def image
      validate_nomis_profile
      success = People::RetrieveImage.call(person)

      if success
        image = Image.new(person.id, person.image.service_url)
        render_json image, serializer: ImageSerializer
      else
        raise ActiveRecord::RecordNotFound, 'Image not found'
      end
    rescue ActiveModel::ValidationError
      raise ActiveRecord::RecordNotFound, 'No NOMIS booking id found'
    end

    def court_cases
      response = People::RetrieveCourtCases.call(person, court_case_filter_params)

      if response.success?
        render_json response.court_cases, serializer: CourtCaseSerializer, include: other_included_relationships
      else
        render json: json_api_errors_for(response.error)
      end
    end

    def timetable
      start_date = Date.parse(timetable_filter_params[:date_from])
      end_date = Date.parse(timetable_filter_params[:date_to])

      response = People::RetrieveTimetable.call(person, start_date, end_date)

      if response.success?
        render_json response.content, serializer: TimetableSerializer, include: other_included_relationships
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
    PERMITTED_FILTER_PARAMS = %i[police_national_computer criminal_records_office prison_number].freeze
    OTHER_SUPPORTED_RELATIONSHIPS = %w[location].freeze

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

    def validate_other_include_params
      # Custom validation for includes to avoid the default validation shared in API controller
      IncludeParamsValidator
        .new(other_included_relationships, OTHER_SUPPORTED_RELATIONSHIPS)
        .fully_validate!
    end

    def filter_params
      params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
    end
  end
end
