# frozen_string_literal: true

module HealthChecks
  class GovUkNotify
    URL = 'https://status.notifications.service.gov.uk'
    COMPONENTS = ['API', 'Email sending'].freeze
    OPERATIONAL = 'operational'

    def status
      healthy = false
      begin
        response = client.get(URL)
        if response.success?
          data = JSON.parse(client.get(URL).body)

          # NB this produces a hash e.g. {"API"=>true, "Email sending"=>false}
          components = data['components']
                           .select { |c| COMPONENTS.include?(c['name']) }
                           .map { |c| [c['name'], c['status'] == OPERATIONAL] }
                           .to_h

          healthy = components.keys.sort == COMPONENTS.sort && !components.values.include?(false)
          log_warning(components) unless healthy
        else
          log_warning(response: response.status)
        end
      rescue StandardError => e
        log_warning(error: e.message)
      end
      healthy
    end

  private

    def client
      Faraday.new(headers: { 'Accept': 'application/json', 'User-Agent': 'hmpps-book-a-secure-move/v1' })
    end

    def log_warning(details)
      Rails.logger.warn("[GovUkNotify] service is unhealthy: #{details.to_json}")
      Raven.capture_message('[GovUkNotify] service is unhealthy', extra: details, level: 'warning')
    end
  end
end
