# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with success 200' do
  it 'returns a success code' do
    expect(response).to have_http_status(200)
  end

  it 'returns a valid 200 JSON response', with_json_schema: true do
    expect(JSON::Validator.validate!(schema, response_json, fragment: '#/200')).to be true
  end

  it 'sets the correct content type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
  end
end
