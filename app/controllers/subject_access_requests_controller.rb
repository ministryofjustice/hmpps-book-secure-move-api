# frozen_string_literal: true

class SubjectAccessRequestsController < ApiController
  before_action :check_scope

  def check_scope
    unless doorkeeper_token.acceptable?(:'subject-access-request')
      render json: { error: 'missing scope: subject-access-request' }, status: :forbidden
    end
  end

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
