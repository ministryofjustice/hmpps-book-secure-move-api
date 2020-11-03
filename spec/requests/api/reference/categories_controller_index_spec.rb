# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::CategoriesController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { 'spoofed-token' }
  let(:headers) do
    {
      'CONTENT_TYPE': ApiController::CONTENT_TYPE,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'GET /reference/categories' do
    before do
      create(:category, :not_supported, key: 'A', title: 'Cat A')
      create(:category, key: 'B', title: 'Cat B')
      get '/api/reference/categories', headers: headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(:ok)
      expect(response_json).to eql({ 'data' => [
        { 'attributes' => { 'move_supported' => false, 'title' => 'Cat A' }, 'id' => 'A', 'type' => 'categories' },
        { 'attributes' => { 'move_supported' => true, 'title' => 'Cat B' }, 'id' => 'B', 'type' => 'categories' },
      ] })
    end
  end
end
