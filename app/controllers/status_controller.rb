# frozen_string_literal: true

class StatusController < ApplicationController
  NOT_AVAILABLE = 'Not available'

  def ping
    json = {
      'build_date' => ENV['APP_BUILD_DATE'] || NOT_AVAILABLE,
      'commit_id' => ENV['APP_GIT_COMMIT'] || NOT_AVAILABLE,
      'build_tag' => ENV['APP_BUILD_TAG'] || NOT_AVAILABLE,
    }.to_json

    render json:
  end

  def health
    checks = {
      database: database_connected?,
    }

    status = checks.values.all? ? :ok : :bad_gateway
    render status:,
           json: {
             checks:,
             healthy: checks.values.all? { |val| val == true },
           }
  end

private

  def database_connected?
    ActiveRecord::Base.with_connection do |conn|
      conn.execute('SELECT 1').present?
    end
  rescue StandardError
    false
  end
end
