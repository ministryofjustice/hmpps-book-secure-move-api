# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with error 409' do
  let(:errors_409) do
    [{
        'title' => 'Idempotency Conflict Error',
        'detail' => detail_409,
    }]
  end

  it 'returns a resource not found error code' do
    expect(response).to have_http_status(:conflict)
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_409)
  end

  it 'returns a valid 409 JSON response' do
    expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/409')).to be true
  end

  it 'sets the correct content type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))
  end
end
