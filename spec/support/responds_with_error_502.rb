# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with error 502' do
  let(:response_json) { JSON.parse(response.body) }
  let(:errors_502) do
    [
      {
        'title' => 'Nomis Bad Gateway Error',
        'detail' => /OAuth2::Error/,
      },
    ]
  end

  it 'returns bad request error code' do
    expect(response).to have_http_status(:bad_gateway)
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_502)
  end

  it 'returns a valid 502 JSON response' do
    expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/502')).to be true
  end

  it 'sets the correct content type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))
  end
end
