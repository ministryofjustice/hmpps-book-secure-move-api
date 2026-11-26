# frozen_string_literal: true

class StatusController < ApplicationController
  NOT_AVAILABLE = 'Not available'

  def ping
    json = {
      'build_date' => ENV['APP_BUILD_DATE'].presence || NOT_AVAILABLE,
      'commit_id' => BuildInfo.git_ref || NOT_AVAILABLE,
      'build_tag' => BuildInfo.build_number || NOT_AVAILABLE,
    }.to_json

    render json:
  end

  # HMPPS standard health endpoint, read by the Developer Portal. Also keeps
  # the original `checks` and `healthy` fields for anything still using them
  def health
    checks = {
      database: database_connected?,
    }
    healthy = checks.values.all?
    status = healthy ? 'UP' : 'DOWN'

    render status: healthy ? :ok : :service_unavailable,
           json: {
             status:,
             components: {
               db: { status: checks[:database] ? 'UP' : 'DOWN' },
             },
             build: {
               buildNumber: BuildInfo.build_number,
               gitRef: BuildInfo.git_ref,
             },
             version: BuildInfo.build_number,
             uptime: BuildInfo.uptime,
             checks:,
             healthy:,
           }
  end

  # HMPPS standard info endpoint, read by the Developer Portal drift radiator
  def info
    render json: {
      git: {
        branch: BuildInfo.git_branch,
        commit: { id: BuildInfo.git_ref },
      },
      build: {
        artifact: BuildInfo::APP_NAME,
        name: BuildInfo::APP_NAME,
        version: BuildInfo.build_number,
      },
      productId: BuildInfo.product_id,
      uptime: BuildInfo.uptime,
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
