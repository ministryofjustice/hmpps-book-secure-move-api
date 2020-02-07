# frozen_string_literal: true

module Api
  module V1
    class PeopleController < ApiController
      def index
        profiles = Profiles::Finder.new(filter_params).call
        paginate profiles, include: ProfileSerializer::INCLUDED_DETAIL
      end

      def create
        creator.call
        render_person(creator.person, 201)
      end

      def update
        updater.call
        render_person(updater.person, 200)
      end

    private

      PERMITTED_FILTER_PARAMS = [:police_national_computer].freeze
      PERSON_ATTRIBUTES = [
        :first_names,
        :last_name,
        :date_of_birth,
        :gender_additional_information,
        assessment_answers: [%i[key date expiry_data category title comments assessment_question_id]],
        identifiers: [%i[value identifier_type]],
      ].freeze
      PERMITTED_PERSON_PARAMS = [:type, attributes: PERSON_ATTRIBUTES, relationships: {}].freeze

      def creator
        @creator ||= People::Creator.new(person_params)
      end

      def updater
        @updater ||= People::Updater.new(params[:id], person_params)
      end

      def render_person(person, status)
        render json: person.latest_profile, status: status, include: ProfileSerializer::INCLUDED_DETAIL
      end

      def person_params
        params.require(:data).permit(PERMITTED_PERSON_PARAMS).to_h
      end

      def filter_params
        params.require(:filter).permit(PERMITTED_FILTER_PARAMS).to_h
      end
    end
  end
end
