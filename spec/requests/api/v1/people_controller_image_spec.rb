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

      it 'returns resource not found 404' do
        id = 'non-existent-id'

        get "/api/v1/people/#{id}/image", params: { access_token: token.token }

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with an image' do
      subject(:get_image) { get "/api/v1/people/#{person.id}/image", params: { access_token: token.token } }

      let!(:person) { create(:profile, :nomis_synced).person }
      let(:image_data) { File.read('spec/fixtures/Arctic_Tern.jpg') }


      before do
        allow(NomisClient::Image).to receive(:get).and_return(image_data)
      end

      it 'returns success' do
        get_image

        expect(response).to be_successful
      end

      it 'contains the url of the image' do
        get_image

        expect(JSON.parse(response.body)['url']).to include person.id + '.jpg'
      end

      context 'when an image is already attached to the person' do
        it 'returns the image already attached' do
          person.attach_picture('image_data')

          get_image

          expect(NomisClient::Image).not_to have_received(:get)
        end
      end
    end
  end
end
