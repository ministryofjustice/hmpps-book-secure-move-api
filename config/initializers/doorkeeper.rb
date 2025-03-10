# frozen_string_literal: true

Doorkeeper.configure do
  # Change the ORM that doorkeeper will use (needs plugins)
  orm :active_record

  # Configure for API-only mode
  api_only

  # Enable application owner
  enable_application_owner confirmation: false

  # Hash application secrets using BCrypt except in test environment
  hash_application_secrets using: '::Doorkeeper::SecretStoring::BCrypt' unless Rails.env.test?

  # IMPORTANT: Add these settings to fix 401 errors after upgrade
  # 1. Update token methods to ensure all authorization headers are properly parsed
  access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param
  # 2. Set application class - this helps with your current_user implementation
  resource_owner_from_credentials do
    # In your case, this isn't used since you're using client_credentials
    nil
  end

  # 3. Enhanced error handling
  handle_auth_errors :standard

  # 4. Set a reasonable token expiration (adjust as needed)
  access_token_expires_in 24.hours

  # 5. Allow token reuse to prevent database bloat
  reuse_access_token

  # 6. Ensure proper fallback to plain secrets for existing tokens
  # Uncomment if you previously weren't hashing tokens but now are
  # fallback_to_plain_secrets

  # Client credentials settings - make sure headers are parsed properly
  client_credentials :from_basic, :from_params

  # Only allow client_credentials flow as in your original config
  grant_flows %w[client_credentials]

  # Define a custom token response to include additional information if needed
  # Uncomment and customize if you want extra fields in token response
  # custom_access_token_response do |token, application|
  #   {
  #     token_type: 'bearer',
  #     access_token: token.token,
  #     expires_in: token.expires_in,
  #     created_at: token.created_at.to_i,
  #     application: {
  #       uid: application.uid,
  #       name: application.name
  #     }
  #   }
  # end

  # Add a hook to log token creation/usage for debugging
  # Uncomment this if you want to debug token issues
  # before_successful_strategy_response do |request|
  #   Rails.logger.info "Doorkeeper strategy success: #{request.client.uid}"
  # end

  # after_successful_strategy_response do |request, response|
  #   Rails.logger.info "Doorkeeper token issued: #{response.token.token}"
  # end
end