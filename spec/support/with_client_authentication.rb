# frozen_string_literal: true

# Disable rubocop rule to improve test running performance
# rubocop:disable RSpec/InstanceVariable
RSpec.shared_context 'with client authentication', shared_context: :metadata do
  before(:all) do
    application = Doorkeeper::Application.create(name: 'test')
    credentials = "#{application.uid}:#{application.plaintext_secret}"

    session = ActionDispatch::Integration::Session.new(Rails.application)
    session.process(
      :post,
      '/oauth/token',
      params: { grant_type: 'client_credentials' },
      headers: { 'Authorization': "Basic #{Base64.strict_encode64(credentials)}" }
    )

    @access_token = JSON.parse(session.response.body)['access_token']
  end

  let(:auth_headers) { { 'Authorization': "Bearer #{@access_token}" } }
end

RSpec.shared_context 'with invalid authentication request headers', shared_context: :metadata do
  let(:auth_headers) { { 'Authorization': 'Bearer invalid-token' } }
end

RSpec.configure do |rspec|
  rspec.include_context 'with client authentication', with_client_authentication: true
  rspec.include_context 'with invalid authentication request headers', with_invalid_auth_headers: true
end
# rubocop:enable RSpec/InstanceVariable
