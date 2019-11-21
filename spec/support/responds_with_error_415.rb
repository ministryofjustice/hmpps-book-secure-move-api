# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with error 415' do
  let(:errors_415) do
    [
      {
        'title' => 'Invalid Media Type',
        'detail' => 'Content-Type must be application/vnd.api+json'
      }
    ]
  end

  it 'returns invalid media type error code' do
    expect(response).to have_http_status(:unsupported_media_type)
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_415)
  end

  it 'returns a valid 415 JSON response', with_json_schema: true do
    expect(JSON::Validator.validate!(schema, response_json, fragment: '#/415')).to be true
  end

  it 'sets the correct content type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))
  end
end
