# frozen_string_literal: true

module Api
  class PersonEscortRecordsController < ApiController
    NEW_PERMITTED_PER_PARAMS = [
      :type,
      attributes: [:version],
      relationships: [profile: {}],
    ].freeze

    def create
      person_escort_record = PersonEscortRecord.save_with_responses!(
        version: new_person_escort_record_params.dig(:attributes, :version),
        profile_id: new_person_escort_record_params.dig(:relationships, :profile, :data, :id),
      )

      render_person_escort_record(person_escort_record, :created)
    end

    def show
      person_escort_record = PersonEscortRecord.find(params[:id])

      render_person_escort_record(person_escort_record, :ok)
    end

  private

    def new_person_escort_record_params
      params.require(:data).permit(NEW_PERMITTED_PER_PARAMS).to_h
    end

    def supported_relationships
      PersonEscortRecordSerializer::SUPPORTED_RELATIONSHIPS
    end

    def render_person_escort_record(person_escort_record, status)
      render json: person_escort_record, status: status, include: included_relationships
    end
  end
end
