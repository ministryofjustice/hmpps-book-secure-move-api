# frozen_string_literal: true

class SubjectAccessRequestsController < HmppsAuthApiController
  SAR_ROLE = 'ROLE_SAR_DATA_ACCESS'

  def show
    validated_params = SubjectAccessRequests::ParamsValidator.new(show_params)
    unless validated_params.valid?
      return render json: { error: validated_params.errors }, status: :bad_request
    end

    if show_params[:prn].blank? && show_params[:crn].present?
      return render status: 209
    end

    if sar.empty?
      return render status: :no_content
    end

    render json: sar.fetch, status: :ok
  end

private

  PERMITTED_SHOW_PARAMS = %i[
    prn crn from_date to_date
  ].freeze

  # Overrides parent due to endpoint-specific roles
  def verify_token
    unless token.valid_token_with_scope?('read', role: SAR_ROLE)
      if token.valid_token_with_scope?('read', role: '')
        render_error("Missing role: #{SAR_ROLE}", 1, 403)
      else
        render_error('Valid authorisation token required', 1, 401)
      end
    end
  end

  # Overrides parent due to endpoint-specific error schema
  def render_error(msg, error_code, status)
    render json: {
      developerMessage: msg,
      errorCode: error_code,
      status:,
      userMessage: msg,
    }, status: status.to_s
  end

  def show_params
    @show_params ||= params.permit(PERMITTED_SHOW_PARAMS)
  end

  def from_date
    @from_date ||= show_params[:from_date].present? ? Date.parse(show_params[:from_date]) : Date.new(1000)
  end

  def to_date
    @to_date ||= show_params[:to_date].present? ? Date.parse(show_params[:to_date]) : Date.new(3000)
  end

  def sar
    @sar ||= SubjectAccessRequest.new(show_params[:prn], show_params[:from_date], show_params[:to_date])
  end
end
