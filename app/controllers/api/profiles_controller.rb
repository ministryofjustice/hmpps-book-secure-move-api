# frozen_string_literal: true

module Api
  class ProfilesController < ApiController
    def create
      profile = person.profiles.create(profile_attributes)

      if person.prison_number.present? && profile_attributes[:assessment_answers].blank?
        Profiles::ImportAlertsAndPersonalCareNeeds.new(profile, person.prison_number).call
      end

      render_profile(profile, :created)
    end

    def update
      profile = person.profiles.find(params.require(:id))

      profile.update!(profile_attributes)
      Notifier.prepare_notifications(topic: profile.person, action_name: 'update')

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
      relationships: {},
    ].freeze

    def profile_attributes
      profile_attributes = profile_params.fetch(:attributes, {})
      profile_attributes[:documents] = documents unless document_attributes.nil?
      profile_attributes
    end

    def documents
      Document.where(id: document_ids)
    end

    def document_ids
      @document_ids ||= document_attributes&.map { |doc| doc[:id] }
    end

    def document_attributes
      @document_attributes ||= profile_params.dig(:relationships, :documents, :data)
    end

    def profile_params
      params.require(:data).permit(PROFILE_ATTRIBUTES).to_h
    end

    def person
      @person ||= Person.find(params.require(:person_id))
    end

    def supported_relationships
      ProfileSerializer::SUPPORTED_RELATIONSHIPS
    end

    def render_profile(profile, status)
      render json: profile, status: status, include: included_relationships, serializer: ProfileSerializer
    end
  end
end
