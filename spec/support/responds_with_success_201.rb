# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with success 201' do
  it 'returns a success code' do
    expect(response).to have_http_status(:created)
  end

  it 'returns a valid 201 JSON response' do
    # TODO: rewrite this test to give meaningful errors, rather than "The property '#/' did not contain a required property of 'data'"
    expect(JSON::Validator.validate!(schema, response_json, fragment: '#/201')).to be true
  end

  it 'sets the correct content type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))
  end
end
