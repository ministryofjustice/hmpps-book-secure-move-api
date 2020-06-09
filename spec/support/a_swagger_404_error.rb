# frozen_string_literal: true

RSpec.shared_examples 'a swagger 404 error' do
  let(:errors_404) do
    [
      {
        'title' => 'Resource not found',
        'detail' => detail_404,
      },
    ]
  end

  schema '$ref' => 'error_responses.yaml#/404'

  run_test!

  it 'sets the Content-Type header' do
    expect(response.headers['Content-Type']).to match(Regexp.escape(content_type))
  end

  it 'returns errors in the body of the response' do
    expect(JSON.parse(response.body)).to include_json(errors: errors_404)
  end
end
