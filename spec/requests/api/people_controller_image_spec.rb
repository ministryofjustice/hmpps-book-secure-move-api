# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PeopleController do
  subject(:get_image) { get "/api/v1/people/#{id}/images", headers: headers }

  let(:id) { person.id }
  let(:access_token) { 'spoofed-token' }
  let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}" } }
  let(:content_type) { ApiController::CONTENT_TYPE }

  context 'when person ID is NOT valid' do
    let(:id) { 'non-existent-id' }

    it 'not found 404' do
      get_image

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when person ID is valid' do
    let!(:person) { create(:person, :nomis_synced, latest_nomis_booking_id: 'foobar') }
    let(:image_data) { File.read('spec/fixtures/Arctic_Tern.jpg') }

    context 'when there is an image associated with the person in NOMIS' do
      before do
        allow(NomisClient::Image).to receive(:get).and_return(image_data)
      end

      it 'returns success' do
        get_image

        expect(response).to be_successful
      end

      it 'contains the url of the image' do
        get_image

        expect(JSON.parse(response.body)['data']['id']).to eq(person.id)
        expect(JSON.parse(response.body)['data']['attributes']['url']).to include "#{person.id}.jpg"
      end

      it 'returns the image if image was already attached' do
        person.attach_image('image_data')

        get_image

        expect(NomisClient::Image).not_to have_received(:get)
        expect(JSON.parse(response.body)['data']['id']).to eq(person.id)
      end
    end

    context 'when there is NOT an image associated with the person in NOMIS' do
      it 'return not found 404' do
        allow(NomisClient::Image).to receive(:get).and_return(nil)

        get_image

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
