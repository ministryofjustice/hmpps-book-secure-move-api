# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with error 400' do
  let(:response_json) { JSON.parse(response.body) }
  let(:schema) { load_yaml_schema('error_responses.yaml') }
  let(:errors_400) do
    [
      {
        'title' => 'Bad request',
        'detail' => /param is missing or the value is empty/,
      },
    ]
  end

  it 'returns bad request error code' do
    expect(response).to have_http_status(:bad_request)
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_400)
  end

  it 'returns a valid 400 JSON response' do
    expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/400')).to be true
  end

  it 'sets the correct content type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))
  end
end
