# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::ImportPrisonerCategory do
  let(:call) { described_class.new(profile).call }
  let(:person) { create(:person, latest_nomis_booking_id: latest_nomis_booking_id) }
  let(:profile) { create(:profile, person: person) }
  let(:category) { create(:category) }

  context 'with a person who has a latest_nomis_booking_id' do
    let(:latest_nomis_booking_id) { 123 }

    before do
      allow(NomisClient::BookingDetails).to receive(:get).and_return({ category: category.title, category_code: category.key })
    end

    it 'calls GetPrisonerCategoryAttributes with the latest_nomis_booking_id' do
      call
      expect(NomisClient::BookingDetails).to have_received(:get).with(123)
    end

    it 'sets the profile category' do
      call
      expect(profile.category).to eql(category)
    end
  end

  context 'with person who does not have a latest_nomis_booking_id' do
    let(:latest_nomis_booking_id) { nil }

    before do
      allow(NomisClient::BookingDetails).to receive(:get).and_return({ category: nil, category_code: nil })
    end

    it 'calls GetPrisonerCategoryAttributes with the latest_nomis_booking_id' do
      call
      expect(NomisClient::BookingDetails).to have_received(:get).with(nil)
    end

    it 'does not set the profile category' do
      call
      expect(profile.category).to be_nil
    end
  end
end
