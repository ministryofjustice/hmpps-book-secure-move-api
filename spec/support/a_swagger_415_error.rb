# frozen_string_literal: true

RSpec.shared_examples 'a swagger 415 error' do
  let(:"Content-Type") { 'application/xml' }
  let(:errors_415) do |example|
    [
      {
        'title' => 'Invalid Media Type',
        'detail' => "Content-Type must be #{example.metadata[:operation][:produces].first}",
      },
    ]
  end

  schema '$ref' => 'error_responses.yaml#/415'

  run_test!

  it 'sets the Content-Type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(content_type))
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_415)
  end
end
