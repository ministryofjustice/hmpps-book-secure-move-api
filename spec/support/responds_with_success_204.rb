# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with success 204' do
  it 'returns a success code and no content' do
    expect(response).to have_http_status(:no_content)
    expect(response.body).to be_empty
  end
end
