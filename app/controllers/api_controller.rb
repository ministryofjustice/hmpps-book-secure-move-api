# frozen_string_literal: true

class ApiController < ApplicationController
  before_action :restrict_content_type
  after_action :set_content_type

  JSON_API_CONTENT_TYPE = 'application/vnd.api+json'

  rescue_from ActiveRecord::RecordNotFound, with: :render_resource_not_found_error

  private

  def restrict_content_type
    return if request.content_type == JSON_API_CONTENT_TYPE

    render_invalid_media_type_error
  end

  def set_content_type
    self.content_type = JSON_API_CONTENT_TYPE
  end

  def render_resource_not_found_error(exception)
    render(
      json: { errors: [{
        title: 'Resource not found',
        detail: exception.to_s
      }] },
      status: 404
    )
  end

  def render_invalid_media_type_error
    render(
      json: { errors: [{
        title: 'Invalid Media Type',
        detail: "Content-Type must be #{JSON_API_CONTENT_TYPE}"
      }] },
      status: 415
    )
  end
end
