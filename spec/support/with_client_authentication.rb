# frozen_string_literal: true

# TODO: Remove this file completely when none of the specs are using rswag tag

RSpec.shared_context 'with client authentication', shared_context: :metadata do
  let(:valid_bearer_header_value) { "Bearer spoofed-token" }
  let(:auth_headers) { { 'Authorization': valid_bearer_header_value } }

  # RSwag tests automagically add this into header where it's a defined parameter
  let!(:Authorization) { valid_bearer_header_value }
end

RSpec.configure do |rspec|
  rspec.include_context 'with client authentication', with_client_authentication: true
end
