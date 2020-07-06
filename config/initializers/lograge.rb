Rails.application.configure do
  config.lograge.base_controller_class = 'ActionController::API'
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    {
      remote_ip: event.payload[:remote_ip],
      request_id: event.payload[:request_id],
      idempotency_key: event.payload[:idempotency_key],
      client_id: event.payload[:client_id],
      supplier_name: event.payload[:supplier_name],
      api_version: event.payload[:api_version],
      params: event.payload[:params].slice(:filter), # NB: Be careful with what you send to the logs, here.
    }
  end
end
