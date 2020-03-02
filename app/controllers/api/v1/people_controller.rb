# frozen_string_literal: true

module Api
  module V1
    class PeopleController < ApiController
      def index
        person_nomis_prison_number = filter_params[:nomis_offender_no]

        Moves::ImportPeople.new([person_nomis_prison_number: person_nomis_prison_number]).call if person_nomis_prison_number

        people = People::Finder.new(filter_params).call

        paginate people, include: PersonSerializer::INCLUDED_DETAIL
      end

      def create
        creator.call
        render_person(creator.person, 201)
      end

      def update
        updater.call
        render_person(updater.person, 200)
      end

      def image
        person = Person.find(params[:person_id])
        image_data = NomisClient::Image::get(person.latest_profile.latest_nomis_booking_id)

        if image_data
          send_data image_data, type: 'image/jpg', disposition: 'inline'
        else
          render status: :not_found
        end
      end

    private

      PERMITTED_FILTER_PARAMS = %i[police_national_computer nomis_offender_no].freeze
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
        render json: person, status: status, include: PersonSerializer::INCLUDED_DETAIL
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
