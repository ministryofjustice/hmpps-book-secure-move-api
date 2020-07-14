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

      render json: person_escort_record, status: :created, include: included_relationships
    end

    def update
      per.update!(state: params[:data][:attributes][:status])

      h = ActiveModelSerializers::Adapter.create(PersonEscortRecordSerializer.new(per), include: included_relationships).serializable_hash
      render json: meta.merge(h), status: :ok
    end

    def show
       h = ActiveModelSerializers::Adapter.create(PersonEscortRecordSerializer.new(per), include: included_relationships).serializable_hash
      render json: meta.merge(h), status: :ok
    end

  private

    def new_person_escort_record_params
      params.require(:data).permit(NEW_PERMITTED_PER_PARAMS).to_h
    end

    def supported_relationships
      PersonEscortRecordSerializer::SUPPORTED_RELATIONSHIPS
    end

    def per
      @per ||= PersonEscortRecord.find(params[:id])
    end

    def meta
      {
        'meta' => {
          'section_progress' => {
            'health-information' => calculate_progress('health-information'),
            'offence-information' => calculate_progress('offence-information'),
            'risk-information' => calculate_progress('risk-information'),
          }
        }
      }
    end

    def calculate_progress(section)
      responses = per.framework_responses.includes(:framework_question).where(framework_questions: {section: section}).pluck(:responded).uniq
      if responses.include?(true)
        responses.include?(false) ? 'in_progress' : 'completed'
      else
        'not_started'
      end
    end
  end
end
