# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with error 404' do
  let(:errors_404) do
    [
      {
        'title' => 'Resource not found',
        'detail' => detail_404
      }
    ]
  end

  it 'returns a resource not found error code' do
    expect(response).to have_http_status(404)
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_404)
  end

  it 'returns a valid 404 JSON response', with_json_schema: true do
    expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/404')).to be true
  end

  it 'sets the correct content type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
  end
end
