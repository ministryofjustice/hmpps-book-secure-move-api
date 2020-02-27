# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PeopleController do
  describe 'GET /people/:id/image' do
    let(:token) { create(:access_token) }

    context 'when there is no image' do
      let!(:person) { create(:profile, latest_nomis_booking_id: 123_456_789).person }

      it 'returns 404' do
        get "/api/v1/people/#{person.id}/image", params: { access_token: token.token }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with an image' do
      let!(:person) { create(:profile, latest_nomis_booking_id: 1_153_753).person }

      it 'returns success' do
        get "/api/v1/people/#{person.id}/image", params: { access_token: token.token }
        expect(response).to be_successful
      end
    end
  end
end
