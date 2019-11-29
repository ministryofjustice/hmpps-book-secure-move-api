# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with error 422' do
  it 'returns unprocessable entity error code' do
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_422)
  end

  it 'returns a valid 422 JSON response', with_json_schema: true do
    expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/422')).to be true
  end

  it 'sets the correct content type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))
  end
end
