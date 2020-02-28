# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PeopleController do
  describe 'GET /people/:id/image' do
    let(:token) { create(:access_token) }

    context 'when there is no image' do
      let!(:person) { create(:profile, :nomis_synced).person }

      before do
        allow(NomisClient::Image).to receive(:get).and_return(nil)
      end

      it 'returns 404' do
        get "/api/v1/people/#{person.id}/image", params: { access_token: token.token }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with an image' do
      let!(:person) { create(:profile, :nomis_synced).person }
      let(:image_data) { File.read('spec/fixtures/Arctic_Tern.jpg') }

      before do
        allow(NomisClient::Image).to receive(:get).and_return(image_data)

        get "/api/v1/people/#{person.id}/image", params: { access_token: token.token }
      end

      it 'returns success' do
        expect(response).to be_successful
      end

      it 'returns the image' do
        expect(response.body).to eq(image_data)
      end
    end
  end
end
