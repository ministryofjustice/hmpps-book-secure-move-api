# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::CategoriesController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { 'spoofed-token' }
  let(:headers) do
    {
      'CONTENT_TYPE': ApiController::CONTENT_TYPE,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end
  let(:filter_params) { { filter: { person_id: person.id } } }
  let(:person) { create(:person, latest_nomis_booking_id: 123) }

  describe 'GET /categories?filter[person_id]={person with category}' do
    before do
      allow(NomisClient::BookingDetails).to receive(:get).and_return({ category: 'Cat A', category_code: 'A' })
    end

    it 'returns 200' do
      get '/api/categories', params: filter_params, headers: headers

      expect(response).to have_http_status(:ok)
      expect(response_json).to eql(
        { 'data' => [{ 'attributes' => { 'move_supported' => false, 'title' => 'Cat A' }, 'id' => 'A', 'type' => 'categories' }] },
      )
    end
  end

  describe 'GET /categories?filter[person_id]={person without category}' do
    before do
      allow(NomisClient::BookingDetails).to receive(:get).and_return({ category: nil, category_code: nil })
    end

    it 'returns 200' do
      get '/api/categories', params: filter_params, headers: headers

      expect(response).to have_http_status(:ok)
      expect(response_json).to eql({ 'data' => [] })
    end
  end

  describe 'GET /categories?filter[person_id]={missing person}' do
    let(:filter_params) { { filter: { person_id: 'missing-person-id' } } }

    before do
      allow(NomisClient::BookingDetails).to receive(:get).and_return({ category: nil, category_code: nil })
    end

    it 'returns 404' do
      get '/api/categories', params: filter_params, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response_json).to eql({ 'errors' => [{ 'detail' => "Couldn't find Person with 'id'=missing-person-id", 'title' => 'Resource not found' }] })
    end
  end

  describe 'GET /categories' do
    before do
      allow(NomisClient::BookingDetails).to receive(:get).and_return({ category: nil, category_code: nil })
    end

    it 'returns 404' do
      get '/api/categories', headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response_json).to eql({ 'errors' => [{ 'detail' => "Couldn't find Person without an ID", 'title' => 'Resource not found' }] })
    end
  end
end
