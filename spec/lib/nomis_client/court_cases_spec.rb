# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::CourtCases, :with_nomis_client_authentication do
  describe '.get' do
    let(:booking_id) { '1495077' }
    let(:filter_params) { nil }

    it 'calls the nomis client with the correct booking id' do
      described_class.get(booking_id, filter_params)

      expect(token).to have_received(:get).with('/api/bookings/1495077/court-cases', {})
    end

    context 'when no filter_params are passed' do
      it 'returns active court cases' do
        described_class.get(booking_id)

        expect(token).to have_received(:get).with("/api/bookings/#{booking_id}/court-cases?activeOnly=true", {})
      end
    end

    context 'when filter_params are present' do
      let(:filter_params) { ActionController::Parameters.new(active: 'true') }

      it 'returns active court cases' do
        described_class.get(booking_id, filter_params)

        expect(token).to have_received(:get).with("/api/bookings/#{booking_id}/court-cases?activeOnly=true", {})
      end
    end
  end
end
