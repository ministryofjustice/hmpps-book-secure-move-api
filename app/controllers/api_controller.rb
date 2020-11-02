# frozen_string_literal: true

class ApiController < ApplicationController
  include ActiveStorage::SetCurrent # Sets host for service_url
  include Serializable

  DEFAULT_API_VERSION = '1'

  before_action :doorkeeper_authorize!, if: :authentication_enabled?
  before_action :restrict_request_content_type
  before_action :restrict_request_api_version
  before_action :extend_versioned_controller_actions
  before_action :set_content_type
  before_action :set_paper_trail_whodunnit
  before_action :validate_include_params

  CONTENT_TYPE = 'application/vnd.api+json'
  REGEXP_API_VERSION = %r{.*version=(?<version>\d+)}.freeze

  rescue_from ActionController::ParameterMissing, with: :render_bad_request_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_resource_not_found_error
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_error
  rescue_from ActiveRecord::ReadOnlyRecord, with: :render_resource_readonly_error
  rescue_from CanCan::AccessDenied, with: :render_unauthorized_error
  rescue_from ActiveModel::ValidationError, with: :render_validation_error
  rescue_from IncludeParamsValidator::ValidationError, with: :render_include_validation_error

  # Nomis connection errors:
  rescue_from Faraday::ConnectionFailed, with: :render_connection_error
  rescue_from Faraday::TimeoutError, with: :render_timeout_error

  def current_user
    return Doorkeeper::Application.new unless authentication_enabled?

    doorkeeper_token&.application
  end

  def doorkeeper_application_owner
    current_user&.owner
  end

  def user_for_paper_trail
    return headers['X-Current-User'] if headers['X-Current-User'].present?

    current_user.owner_id
  end

  def info_for_paper_trail
    { user_type: headers['X-Current-User'].present? ? 'user' : 'supplier' }
  end

private

  def authentication_enabled?
    return false if Rails.env.development? && ENV['DEV_DISABLE_AUTH'] =~ /true/i

    return false if Rails.env.production? && ENV['HEROKU_DISABLE_AUTH'] =~ /true/i

    return false if Rails.env.test? && request.headers['Authorization'] =~ /spoofed/i

    true
  end

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

    render_invalid_media_type_error('Invalid Media Type', "Content-Type must be #{restricted_request_content_type}")
  end

  def restrict_request_api_version
    version_supported = %w[1 2]

    return if version_supported.include?(api_version) || api_version.nil?

    render_invalid_media_type_error('Invalid Api Version', "The Api versions supported are: #{version_supported}")
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
    # NB: exception is a ActiveRecord::RecordNotFound, this renders a cleaner error message without a long WHERE id=foo clause
    detail = if exception.id.present?
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

  def render_invalid_media_type_error(title, detail)
    render(
      json: { errors: [{
        title: title,
        detail: detail,
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

  def render_timeout_error(exception)
    render(
      json: { errors: [{
        title: 'Timeout Error',
        detail: "#{exception.exception.class}: #{exception.message}",
      }] },
      status: :gateway_timeout,
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
        title: "Invalid #{exception.model.errors.keys.join(', ')}",
        detail: exception.to_s,
      }] },
      status: :unprocessable_entity, # NB: 422 (Unprocessable Entity) means syntactically correct but semantically incorrect
    )
  end

  def render_include_validation_error(exception)
    render(
      json: {
        errors: exception.errors.map do |field, message|
          { title: field, detail: message }
        end,
      },
      # NB: The json:api specification requires this is a 400
      status: :bad_request,
    )
  end

  def validate_include_params
    include_params_validator.fully_validate!
  end

  def include_params_handler
    @include_params_handler ||= IncludeParamHandler.new(params)
  end

  def included_relationships
    @included_relationships ||= include_params_handler.included_relationships
  end

  def active_record_relationships
    @active_record_relationships ||= include_params_handler.active_record_relationships
  end

  def include_params_validator
    @include_params_validator ||= IncludeParamsValidator.new(included_relationships, supported_relationships)
  end

  def supported_relationships
    []
  end

  def api_version
    res = request.headers['Accept']&.match(REGEXP_API_VERSION)
    res&.[](:version)
  end

  def extend_versioned_controller_actions
    version = "Api::V#{api_version || DEFAULT_API_VERSION}"

    actions_module = "#{controller_name.capitalize}Actions"

    if version.constantize.const_defined?(actions_module)
      extend "#{version}::#{actions_module}".constantize
    end
  end

  def append_info_to_payload(payload)
    super

    payload[:remote_ip] = request.remote_ip
    payload[:request_id] = request.request_id
    payload[:idempotency_key] = request.headers['Idempotency-Key']
    payload[:client_id] = current_user&.uid
    payload[:client_name] = current_user&.name
    payload[:supplier_name] = doorkeeper_application_owner&.name || 'none'
    payload[:api_version] = api_version || DEFAULT_API_VERSION
  end
end
