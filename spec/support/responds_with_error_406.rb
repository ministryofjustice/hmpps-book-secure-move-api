# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with error 406' do
  let(:errors_406) do
    [{
      'title' => 'Not Supported In Old Version Error',
      'detail' => 'This endpoint is not supported in version v1 - please change the ACCEPT header to a newer version',
    }]
  end

  it 'returns a resource not_acceptable error code' do
    expect(response).to have_http_status(:not_acceptable)
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_406)
  end

  it 'returns a valid 406 JSON response' do
    expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/406')).to be true
  end

  it 'sets the correct content type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::CONTENT_TYPE))
  end
end
