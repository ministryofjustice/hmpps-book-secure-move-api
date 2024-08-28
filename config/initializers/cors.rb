# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors, :logger => (-> { Rails.logger }) do

  # Allow any origins for dev environments, because we might be tunnelling, using Docker, etc.
  # otherwise pull from an environment variable for production/staging
  allowed_origins = Rails.env.development? ? '*' : ENV["CORS_ALLOWED_ORIGINS"]
  
  if allowed_origins.present?
    allow do
      origins allowed_origins

      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head]
    end
  end
end
