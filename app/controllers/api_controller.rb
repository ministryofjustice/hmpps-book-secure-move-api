# frozen_string_literal: true

class ApiController < ApplicationController
  before_action :doorkeeper_authorize!
  before_action :restrict_request_content_type
  before_action :set_content_type
  before_action :set_paper_trail_whodunnit

  CONTENT_TYPE = 'application/vnd.api+json'

  rescue_from ActionController::ParameterMissing, with: :render_bad_request_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_resource_not_found_error
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_error
  rescue_from ActiveRecord::ReadOnlyRecord, with: :render_resource_readonly_error
  rescue_from CanCan::AccessDenied, with: :render_unauthorized_error
  rescue_from Faraday::ConnectionFailed, Faraday::TimeoutError, with: :render_connection_error
  rescue_from ActiveModel::ValidationError, with: :render_validation_error

  def current_user
    doorkeeper_token&.application
  end

  def user_for_paper_trail
    current_user.owner_id
  end

private

  def doorkeeper_unauthorized_render_options(*)
    {
      json: {
        errors: [
          {
            title: 'Not authorized',
            detail: 'Token expired or invalid',
          },
        ],
      },
    }
  end

  def restricted_request_content_type
    defined?(@restricted_request_content_type) ? @restricted_request_content_type : CONTENT_TYPE
  end

  def restrict_request_content_type
    return if request.content_type == restricted_request_content_type || valid_empty_request?

    render_invalid_media_type_error
  end

  def set_content_type
    self.content_type = CONTENT_TYPE
  end

  def render_bad_request_error(exception)
    render(
      json: { errors: [{
        title: 'Bad request',
        detail: exception.to_s,
      }] },
      status: :bad_request,
    )
  end

  def render_resource_not_found_error(exception)
    # NB: cleaner error message without a long WHERE id=foo clause
    detail = if exception.is_a?(ActiveRecord::RecordNotFound) && exception.id.present?
               "Couldn't find #{exception.model} with '#{exception.primary_key}'=#{exception.id}"
             else
               exception.to_s
             end
    render(
      json: { errors: [{
        title: 'Resource not found',
        detail: detail,
      }] },
      status: :not_found,
    )
  end

  def render_invalid_media_type_error
    render(
      json: { errors: [{
        title: 'Invalid Media Type',
        detail: "Content-Type must be #{restricted_request_content_type}",
      }] },
      status: :unsupported_media_type,
    )
  end

  def render_unprocessable_entity_error(exception)
    render(
      json: { errors: validation_errors(exception.record) },
      status: :unprocessable_entity,
    )
  end

  def render_resource_readonly_error(exception)
    render(
      json: { errors: [{
        title: 'Forbidden',
        detail: exception.to_s,
      }] },
      status: :forbidden,
    )
  end

  def render_unauthorized_error(exception)
    render(
      json: { errors: [{
        title: 'Not authorized',
        detail: exception.to_s,
      }] },
      status: :unauthorized,
    )
  end

  def render_connection_error(exception)
    render(
      json: { errors: [{
        title: 'Connection Error',
        detail: "#{exception.exception.class}: #{exception.message}",
      }] },
      status: :service_unavailable,
    )
  end

  def validation_errors(record)
    errors = record.errors
    errors.keys.flat_map do |field|
      Array.new(errors[field].size) do |index|
        {
          title: 'Unprocessable entity',
          detail: "#{field} #{errors[field][index]}".humanize,
          source: { pointer: "/data/attributes/#{field}" },
          code: errors.details[field][index][:error],
        }.tap do |error|
          if error[:code] == :taken && record.respond_to?(:existing_id)
            error[:meta] = { existing_id: record.existing_id }
          end
        end
      end
    end
  end

  # Allow always-bodyless requests (GET, DELETE HEAD) to omit the Content-Type
  def valid_empty_request?
    request.content_type.nil? && (request.get? || request.delete? || request.head?)
  end

  def render_validation_error(exception)
    render(
      json: { errors: [{
                         title: "Invalid #{exception.exception.model.errors.keys.join(', ')}",
                         detail: exception.to_s,
                     }] },
      status: :bad_request,
        )
  end
end
