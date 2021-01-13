# frozen_string_literal: true

module Api
  class FrameworkAssessmentsController < ApiController
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
      assessment = assessment_class.save_with_responses!(
        version: new_assessment_params.dig(:attributes, :version),
        move_id: new_assessment_params.dig(:relationships, :move, :data, :id),
      )

      render_assessment(assessment, :created)
    end

    def update
      FrameworkAssessments::ParamsValidator.new(update_assessment_status).validate!
      assessment.confirm!(update_assessment_status)

      render_assessment(assessment, :ok)
    end

    def show
      render_assessment(assessment, :ok)
    end

  private

    def new_assessment_params
      params.require(:data).permit(NEW_PERMITTED_PER_PARAMS).to_h
    end

    def update_assessment_params
      params.require(:data).permit(UPDATE_PERMITTED_PER_PARAMS)
    end

    def update_assessment_status
      update_assessment_params.to_h.dig(:attributes, :status)
    end

    def supported_relationships
      assessment_serializer::SUPPORTED_RELATIONSHIPS
    end

    def assessment
      @assessment ||= assessment_class
        .includes(active_record_relationships)
        .find(params[:id])
    end

    def render_assessment(assessment, status)
      render_json assessment, serializer: assessment_serializer, include: included_relationships, status: status
    end

    def send_notification
      Notifier.prepare_notifications(topic: assessment, action_name: 'update')
    end

    def assessment_class
      raise NotImplementedError
    end

    def assessment_serializer
      raise NotImplementedError
    end
  end
end
