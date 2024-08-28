# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with error 422' do
  it 'returns unprocessable entity error code' do
    expect(response).to have_http_status(:unprocessable_content)
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_422)
  end

  it 'returns a valid 422 JSON response' do
    # validates against draft V4 of the spec. Doesn't need strict = true - it actually breaks some things
    # https://github.com/ruby-json-schema/json-schema/issues/139
    expect(JSON::Validator.validate!(schema, response_json, strict: false, fragment: '#/422')).to be true
  end

  it 'sets the correct content type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))
  end
end
