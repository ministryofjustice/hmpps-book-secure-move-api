# frozen_string_literal: true

class ApiController < ApplicationController
  before_action :restrict_content_type
  after_action :set_content_type
  before_action :authenticate_session

  JSON_API_CONTENT_TYPE = 'application/vnd.api+json'

  private

  def restrict_content_type
    return if request.content_type == JSON_API_CONTENT_TYPE

    render(
      json: { errors: [{ title: "Content-Type must be #{JSON_API_CONTENT_TYPE}" }] },
      status: 415
    )
  end

  def set_content_type
    self.content_type = JSON_API_CONTENT_TYPE
  end

  def authenticate_session
    load_current_user
    return if authenticated?

    render(
      json: { errors: [{ title: 'You must be logged in to use this API' }] },
      status: 401
    )
  end
end
