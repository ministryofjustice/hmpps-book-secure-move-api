# frozen_string_literal: true

class ApiController < ApplicationController
  before_action :restrict_content_type

  JSON_API_CONTENT_TYPE = 'application/vnd.api+json'

  private

  def restrict_content_type
    return if request.content_type == JSON_API_CONTENT_TYPE

    render(
      json: { errors: [{ title: "Content-Type must be #{JSON_API_CONTENT_TYPE}" }] },
      status: 415
    )
  end
end
