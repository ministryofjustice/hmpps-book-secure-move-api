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
  let(:cat_a) { create(:category, :not_supported, key: 'A', title: 'Cat A') }
  let(:cat_b) { create(:category, key: 'B', title: 'Cat B') }

  describe 'GET /reference/categories' do
    before do
      cat_a
      cat_b
      get '/api/reference/categories', headers: headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(:ok)
      expect(response_json).to eql({ 'data' => [
        { 'attributes' => { 'move_supported' => false, 'key' => 'A', 'title' => 'Cat A' }, 'id' => cat_a.id, 'type' => 'categories' },
        { 'attributes' => { 'move_supported' => true, 'key' => 'B', 'title' => 'Cat B' }, 'id' => cat_b.id, 'type' => 'categories' },
      ] })
    end
  end
end
