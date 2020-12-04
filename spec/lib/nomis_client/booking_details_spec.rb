# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::BookingDetails, with_nomis_client_authentication: true do
  describe '.get' do
    let(:response) { described_class.get(12_345) }

    context 'when the booking is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/get_booking_details_200.json').read }

      it 'returns the correct prisoner category' do
        expect(response).to eql({
          category: 'Cat B',
          category_code: 'B',
        })
      end
    end

    context 'when the booking is not found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/get_booking_details_404.json').read }

      it 'returns an unknown catgeory' do
        expect(response).to eql({
          category: nil,
          category_code: nil,
        })
      end
    end
  end
end
