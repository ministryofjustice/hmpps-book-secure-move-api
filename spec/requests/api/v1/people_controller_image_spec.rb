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
        # JPEG files start with FF D8 FF as the first three bytes ...
        # .. and end with FF D9 as the last two bytes. This should be
        # an adequate test to see if we receive a valid JPG from the
        # API call.
        jpeg_start_sentinel = [0xFF, 0xD8, 0xFF]
        jpeg_end_sentinel = [0xFF, 0xD9]

        bytes = response.body.bytes.to_a
        expect(bytes[0, 3]).to eq(jpeg_start_sentinel)
        expect(bytes[-2, 2]).to eq(jpeg_end_sentinel)
      end
    end
  end
end
