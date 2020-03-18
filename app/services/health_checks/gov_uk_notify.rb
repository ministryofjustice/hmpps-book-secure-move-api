# frozen_string_literal: true

module HealthChecks
  class GovUkNotify
    COMPONENTS = ['API', 'Email sending'].freeze
    OPERATIONAL = 'operational'

    def healthy?(force: false)
      # NB: using a short cache (30 seconds) to avoid swamping the govuk notify service
      Rails.cache.fetch('health_checks_gov_uk_notify_healthy', expires_in: 30.seconds, force: force) do
        check_healthy?
      end
    end

  private

    def client
      Faraday.new(headers: { 'Accept': 'application/json', 'User-Agent': 'hmpps-book-a-secure-move/v1' })
    end

    def check_healthy?
      healthy = false
      begin
        response = client.get(ENV.fetch('GOVUK_NOTIFY_STATUS_URL', 'https://status.notifications.service.gov.uk'))
        if response.success?
          data = JSON.parse(response.body)

          # NB this produces a hash e.g. {"API"=>true, "Email sending"=>false}
          components = data['components']
                           .select { |c| COMPONENTS.include?(c['name']) }
                           .map { |c| [c['name'], c['status'] == OPERATIONAL] }
                           .to_h

          # NB: we are healthy if we have checked all the relevant components and they are all true
          healthy = components.keys.sort == COMPONENTS.sort && !components.values.include?(false)
          warning(components) unless healthy
        else
          warning(response: response.status)
        end
      rescue StandardError => e
        warning(error: e.message)
      end
      healthy
    end

    def warning(details)
      Rails.logger.warn("[GovUkNotify] service is unhealthy: #{details.to_json}")
      Raven.capture_message('[GovUkNotify] service is unhealthy', extra: details, level: 'warning')
    end
  end
end
