# frozen_string_literal: true

module Api
  class PersonEscortRecordsController < ApiController
    after_action :send_notification, only: :update

    NEW_PERMITTED_PER_PARAMS = [
      :type,
      attributes: [:version],
      relationships: [move: {}],
    ].freeze

    UPDATE_PERMITTED_PER_PARAMS = [
      :type,
      attributes: [:status],
    ].freeze

    def create
      person_escort_record = PersonEscortRecord.save_with_responses!(
        version: new_person_escort_record_params.dig(:attributes, :version),
        move_id: new_person_escort_record_params.dig(:relationships, :move, :data, :id),
      )

      render_person_escort_record(person_escort_record, :created)
    end

    def update
      PersonEscortRecords::ParamsValidator.new(update_person_escort_record_status).validate!
      person_escort_record.confirm!(update_person_escort_record_status)

      render_person_escort_record(person_escort_record, :ok)
    end

    def show
      render_person_escort_record(person_escort_record, :ok)
    end

  private

    def new_person_escort_record_params
      params.require(:data).permit(NEW_PERMITTED_PER_PARAMS).to_h
    end

    def update_person_escort_record_params
      params.require(:data).permit(UPDATE_PERMITTED_PER_PARAMS)
    end

    def update_person_escort_record_status
      update_person_escort_record_params.to_h.dig(:attributes, :status)
    end

    def supported_relationships
      PersonEscortRecordSerializer::SUPPORTED_RELATIONSHIPS
    end

    def person_escort_record
      @person_escort_record ||= PersonEscortRecord.find(params[:id])
    end

    def render_person_escort_record(person_escort_record, status)
      render_json person_escort_record, serializer: PersonEscortRecordSerializer, include: included_relationships, status: status
    end

    def send_notification
      Notifier.prepare_notifications(topic: person_escort_record, action_name: 'update')
    end
  end
end
