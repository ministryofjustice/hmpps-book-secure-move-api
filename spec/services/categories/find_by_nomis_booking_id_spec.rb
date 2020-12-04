# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Categories::FindByNomisBookingId do
  let(:call) { described_class.new(nomis_booking_id).call }
  let(:category) { create(:category) }

  context 'with a nomis_booking_id which maps to a known category' do
    let(:nomis_booking_id) { 123 }

    before do
      allow(NomisClient::BookingDetails).to receive(:get).and_return({ category: category.title, category_code: category.key })
    end

    it 'calls NomisClient::BookingDetails.get with the nomis_booking_id' do
      call
      expect(NomisClient::BookingDetails).to have_received(:get).with(123)
    end

    it 'returns the correct category' do
      expect(call).to eql(category)
    end
  end

  context 'with a nomis_booking_id which does not map to a known category' do
    let(:nomis_booking_id) { 123 }

    before do
      allow(NomisClient::BookingDetails).to receive(:get).and_return({ category: 'Foo', category_code: 'Foo' })
    end

    it 'calls NomisClient::BookingDetails.get with the nomis_booking_id' do
      call
      expect(NomisClient::BookingDetails).to have_received(:get).with(123)
    end

    it 'returns nil' do
      expect(call).to be_nil
    end
  end

  context 'without a nomis_booking_id' do
    let(:nomis_booking_id) { nil }

    before do
      allow(NomisClient::BookingDetails).to receive(:get).and_return({ category: nil, category_code: nil })
    end

    it 'returns nil' do
      expect(call).to be_nil
    end
  end
end
