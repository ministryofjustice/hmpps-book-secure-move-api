# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with error 403' do
  let(:errors_403) do
    [
      {
        'title' => 'Forbidden',
        'detail' => detail_403
      }
    ]
  end

  it 'returns a resource not found error code' do
    expect(response).to have_http_status(:forbidden)
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_403)
  end

  it 'returns a valid 403 JSON response', with_json_schema: true do
    expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/403')).to be(true)
  end

  it 'sets the correct content type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))
  end
end
