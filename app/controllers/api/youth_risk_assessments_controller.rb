# frozen_string_literal: true

module Api
  class YouthRiskAssessmentsController < ApiController
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
      youth_risk_assessment = YouthRiskAssessment.save_with_responses!(
        version: new_youth_risk_assessment_params.dig(:attributes, :version),
        move_id: new_youth_risk_assessment_params.dig(:relationships, :move, :data, :id),
      )

      render_youth_risk_assessment(youth_risk_assessment, :created)
    end

    def update
      YouthRiskAssessments::ParamsValidator.new(update_youth_risk_assessment_status).validate!
      youth_risk_assessment.confirm!(update_youth_risk_assessment_status)

      render_youth_risk_assessment(youth_risk_assessment, :ok)
    end

    def show
      render_youth_risk_assessment(youth_risk_assessment, :ok)
    end

  private

    def new_youth_risk_assessment_params
      params.require(:data).permit(NEW_PERMITTED_PER_PARAMS).to_h
    end

    def update_youth_risk_assessment_params
      params.require(:data).permit(UPDATE_PERMITTED_PER_PARAMS)
    end

    def update_youth_risk_assessment_status
      update_youth_risk_assessment_params.to_h.dig(:attributes, :status)
    end

    def supported_relationships
      YouthRiskAssessmentSerializer::SUPPORTED_RELATIONSHIPS
    end

    def youth_risk_assessment
      @youth_risk_assessment ||= YouthRiskAssessment.find(params[:id])
    end

    def render_youth_risk_assessment(youth_risk_assessment, status)
      render_json youth_risk_assessment, serializer: YouthRiskAssessmentSerializer, include: included_relationships, status: status
    end
  end
end
