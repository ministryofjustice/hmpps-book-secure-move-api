# frozen_string_literal: true

class StatusController < ApplicationController
  NOT_AVAILABLE = 'Not available'

  def ping
    json = {
      'build_date' => ENV['APP_BUILD_DATE'] || NOT_AVAILABLE,
      'commit_id' => ENV['APP_GIT_COMMIT'] || NOT_AVAILABLE,
      'build_tag' => ENV['APP_BUILD_TAG'] || NOT_AVAILABLE,
    }.to_json

    render json: json
  end

  def health
    checks = {
      database: database_connected?,
      redis: redis_alive?,
    }

    status = checks.values.all? ? :ok : :bad_gateway
    render status: status,
           json: {
             checks: checks,
             healthy: checks.values.all? { |val| val == true },
           }
  end

private

  def redis_alive?
    Sidekiq.redis_info
    true
  rescue StandardError
    false
  end

  def database_connected?
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
  end
end
