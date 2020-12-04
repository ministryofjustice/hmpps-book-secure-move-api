# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::CategoriesController do
  subject(:get_categories) { get '/api/reference/categories', headers: headers }

  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { 'spoofed-token' }
  let(:headers) do
    {
      'CONTENT_TYPE': ApiController::CONTENT_TYPE,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end
  let!(:cat_a) { create(:category, :not_supported, key: 'A', title: 'Cat A') }
  let!(:cat_b) { create(:category, key: 'B', title: 'Cat B') }

  describe 'GET /reference/categories' do
    let(:expected_response) do
      {
        data: [
          {
            id: cat_a.id,
            type: 'categories',
            attributes: {
              move_supported: false,
              key: 'A',
              title: 'Cat A',
              created_at: cat_a.created_at.iso8601,
              updated_at: cat_a.updated_at.iso8601,
            },
          },
          {
            id: cat_b.id,
            type: 'categories',
            attributes: {
              move_supported: true,
              key: 'B',
              title: 'Cat B',
              created_at: cat_b.created_at.iso8601,
              updated_at: cat_b.updated_at.iso8601,
            },
          },
        ],
      }
    end

    before { get_categories }

    it 'returns 200 with expected JSON' do
      expect(response).to have_http_status(:ok)
      expect(response_json).to include_json(expected_response)
    end
  end
end
