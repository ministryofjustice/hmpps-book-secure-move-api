# frozen_string_literal: true

RSpec.shared_examples 'a swagger 401 error' do
  let(:Authorization) { "Basic #{::Base64.strict_encode64('bogus-credentials')}" }
  let(:errors_401) do
    [
      {
        'title' => 'Not authorized',
        'detail' => 'Token expired or invalid',
      },
    ]
  end

  schema '$ref' => 'error_responses.yaml#/401'

  run_test!

  it 'sets the Content-Type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(content_type))
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_401)
  end
end
