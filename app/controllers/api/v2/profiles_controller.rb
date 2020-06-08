# frozen_string_literal: true

module Api
  module V2
    class ProfilesController < ApiController
      def create
        profile = person.profiles.create(new_profile_attributes)
        render_profile(profile, :created)
      end

      def update
        profile = person.profiles.find(params.require(:id))

        profile.update!(update_profile_attributes)
        render_profile(profile, :ok)
      end

    private

      PROFILE_ATTRIBUTES = [
        :type,
        attributes: [
          assessment_answers: [
            %i[
              key
              date
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

      def new_profile_attributes
        # TODO: will be removed once we remove first name and last name from profiles
        profile_params[:attributes].merge(first_names: person.first_names, last_name: person.last_name)
      end

      def update_profile_attributes
        profile_params[:attributes]
      end

      def person
        @person ||= Person.find(params.require(:person_id))
      end

      def supported_relationships
        ::V2::ProfileSerializer::SUPPORTED_RELATIONSHIPS
      end

      def render_profile(profile, status)
        render json: profile, status: status, include: included_relationships, serializer: ::V2::ProfileSerializer
      end
    end
  end
end
