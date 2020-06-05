# frozen_string_literal: true

module Api
  module V2
    class ProfilesController < ApiController
      def create
        profile = person.profiles.create(profile_attributes)
        render json: profile, status: :created, serializer: ::V2::ProfileSerializer
      end

    private

      PROFILE_ATTRIBUTES = [
        :type,
        attributes: [
          assessment_answers: [
            %i[
              key
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
              imported_from_nomis
            ],
          ],
        ],
      ].freeze

      def profile_params
        params.require(:data).permit(PROFILE_ATTRIBUTES).to_h
      end

      def profile_attributes
        # TODO: will be removed once we remove first name and last name from profiles
        profile_params[:attributes].merge(first_names: person.first_names, last_name: person.last_name)
      end

      def person
        @person ||= Person.find(params.require(:person_id))
      end
    end
  end
end
