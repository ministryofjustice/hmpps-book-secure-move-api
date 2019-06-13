# frozen_string_literal: true

module Api
  module V1
    class PeopleController < ApiController
      def create
        creator.call
        render_person(creator.person, 201)
      end

      def update
        updater.call
        render_person(updater.person, 200)
      end

      private

      PERSON_ATTRIBUTES = [
        :first_names,
        :last_name,
        :date_of_birth,
        risk_alerts: [%i[date expiry_data description comments assessment_answer_type_id]],
        health_alerts: [%i[date expiry_data description comments assessment_answer_type_id]],
        court_information: [%i[date expiry_data description comments assessment_answer_type_id]],
        identifiers: [%i[value identifier_type]]
      ].freeze
      PERMITTED_PERSON_PARAMS = [:type, attributes: PERSON_ATTRIBUTES, relationships: {}].freeze

      def creator
        @creator ||= People::Creator.new(person_params)
      end

      def updater
        @updater ||= People::Updater.new(params[:id], person_params)
      end

      def render_person(person, status)
        render json: person, status: status
      end

      def person_params
        params.require(:data).permit(PERMITTED_PERSON_PARAMS).to_h
      end
    end
  end
end
