# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::BookingDetails, :with_hmpps_authentication do
  describe '.get' do
    let(:response) { described_class.get(12_345) }

    context 'when the booking is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/get_booking_details_200.json').read }

      it 'returns the correct data' do
        expect(response).to eql({
          category: 'Cat B',
          category_code: 'B',
          csra: 'Standard',
        })
      end
    end

    context 'when the booking is not found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/get_booking_details_404.json').read }

      it "returns nil'd data" do
        expect(response).to eql({
          category: nil,
          category_code: nil,
          csra: nil,
        })
      end
    end
  end
end
