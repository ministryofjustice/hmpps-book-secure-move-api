# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::GetPrisonerCategoryAttributes do
  let(:call) { described_class.new(nomis_booking_id).call }

  before do
    allow(NomisClient::PrisonerCategory).to receive(:get).and_return({ category: 'Cat B', category_code: 'B' })
  end

  context 'with nomis_booking_id' do
    let(:nomis_booking_id) { 12_345 }

    it 'calls NomisClient::PrisonerCategory' do
      call
      expect(NomisClient::PrisonerCategory).to have_received(:get).with(12_345)
    end

    it 'returns NomisClient::PrisonerCategory' do
      expect(call).to eql({ category: 'Cat B', category_code: 'B' })
    end
  end

  context 'without nomis_booking_id' do
    let(:nomis_booking_id) { nil }

    it 'does not call NomisClient::PrisonerCategory' do
      call
      expect(NomisClient::PrisonerCategory).not_to have_received(:get)
    end

    it 'returns an unknown category' do
      expect(call).to eql({ category: nil, category_code: nil })
    end
  end
end
