# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with error 401' do
  let(:errors_401) do
    [
      {
        'title' => 'Not authorized',
        'detail' => detail_401
      }
    ]
  end

  it 'returns a not authorized error code' do
    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_401)
  end

  it 'returns a valid 401 JSON response', with_json_schema: true do
    expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/401')).to be true
  end

  it 'sets the correct content type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))
  end
end
