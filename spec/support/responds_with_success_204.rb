# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that responds with success 204' do
  it 'returns a success code' do
    expect(response).to have_http_status(:no_content)
  end

  it 'returns an empty response' do
    expect(response.body).to be_empty
  end

  it 'sets does not have a content-type' do
    expect(response.headers['Content-Type']).to be_nil
  end
end
