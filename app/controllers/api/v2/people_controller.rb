# frozen_string_literal: true

module Api
  module V2
    class PeopleController < ApiController
      def index
        prison_number = filter_params[:prison_number]

        import_person_from_nomis(prison_number) if prison_number

        people = People::Finder.new(filter_params).call

        paginate people, include: PersonSerializer::INCLUDED_DETAIL
      end

    private

      def json_api_errors_for(error)
        { errors: [error.json_api_error] }
      end

      def import_person_from_nomis(prison_number)
        # This prevents us from blaming the current user/application for the NOMIS sync
        PaperTrail.request(whodunnit: nil) do
          Moves::ImportPeople.new([prison_number]).call
        end
      rescue StandardError => e
        Raven.capture_exception(e)
      end

      PERMITTED_COURT_CASE_FILTER_PARAMS = %i[active].freeze
      PERMITTED_TIMETABLE_FILTER_PARAMS = %i[date_from date_to].freeze
      PERMITTED_FILTER_PARAMS = %i[police_national_computer prison_number].freeze
      PERSON_ATTRIBUTES = [
        :first_names,
        :last_name,
        :date_of_birth,
        :gender_additional_information,
        assessment_answers: [%i[key
                                date
                                expiry_data
                                category
                                title
                                comments
                                assessment_question_id
                                nomis_alert_type
                                nomis_alert_type_description
                                nomis_alert_code
                                nomis_alert_description
                                created_at
                                expires_at
                                imported_from_nomis]],
        identifiers: [%i[value identifier_type]],
      ].freeze
      PERMITTED_PERSON_PARAMS = [:type, attributes: PERSON_ATTRIBUTES, relationships: {}].freeze

      def creator
        @creator ||= People::Creator.new(person_params)
      end

      def updater
        @updater ||= People::Updater.new(params[:id], person_params)
      end

      def person
        @person ||= Person.find(params[:person_id])
      end

      def render_person(person, status)
        render json: person, status: status, include: PersonSerializer::INCLUDED_DETAIL
      end

      def person_params
        params.require(:data).permit(PERMITTED_PERSON_PARAMS).to_h
      end

      def filter_params
        params.require(:filter).permit(PERMITTED_FILTER_PARAMS).to_h
      end

      def court_case_filter_params
        return unless params[:filter]

        params.require(:filter).permit(PERMITTED_COURT_CASE_FILTER_PARAMS).to_h
      end

      def timetable_filter_params
        params.require(:filter).permit(PERMITTED_TIMETABLE_FILTER_PARAMS).to_h
      end
    end
  end
end
