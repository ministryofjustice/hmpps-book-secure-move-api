# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::ImportPrisonerCategory do
  let(:call) { described_class.new(profile).call }
  let(:person) { create(:person, latest_nomis_booking_id: latest_nomis_booking_id) }
  let(:profile) { create(:profile, person: person) }

  let(:get_prisoner_category) { instance_double(Profiles::GetPrisonerCategoryAttributes, call: { category: 'Cat B', category_code: 'B' }) }

  before do
    allow(Profiles::GetPrisonerCategoryAttributes).to receive(:new) { get_prisoner_category }
  end

  context 'with a person who has a latest_nomis_booking_id' do
    let(:latest_nomis_booking_id) { 123 }

    it 'calls GetPrisonerCategoryAttributes with the latest_nomis_booking_id' do
      call
      expect(get_prisoner_category).to have_received(:call)
    end

    it 'sets the profile category' do
      call
      expect(profile.category).to eql('Cat B')
      expect(profile.category_code).to eql('B')
    end
  end

  context 'with person who does not have a latest_nomis_booking_id' do
    let(:latest_nomis_booking_id) { nil }

    it 'calls GetPrisonerCategoryAttributes with the latest_nomis_booking_id' do
      call
      expect(get_prisoner_category).not_to have_received(:call)
    end

    it 'does not set the profile category' do
      call
      expect(profile.category).to be_nil
      expect(profile.category_code).to be_nil
    end
  end
end
