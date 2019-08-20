# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::Anonymiser do
  describe '.call' do
    subject(:anonymiser) do
      described_class.new(nomis_offender_number: nomis_offender_number)
    end

    before do
      create :location, title: 'PENTONVILLE (HMP)', nomis_agency_id: 'PVI'
      create :location, title: 'LEEDS (HMP)', nomis_agency_id: 'LEI'
      create :location, title: 'MANCHESTER (HMP)', nomis_agency_id: 'MRI'
    end

    let(:nomis_offender_number) { 'Y2835JC' }
    let(:anonymised) { anonymiser.call }

    KEYS = %i[
      offenderNo firstName middleNames lastName dateOfBirth gender sexCode nationalities
      currentlyInPrison latestBookingId latestLocationId latestLocation internalLocation
      pncNumber croNumber ethnicity birthCountry religion convictedStatus
      imprisonmentStatus maritalStatus
    ].freeze

    KEYS.each do |key|
      it "randomly populates the #{key}" do
        expect(anonymised).to have_key(key)
      end
    end

    it 'populates nomis_offender_number with the given key' do
      expect(anonymised[:offenderNo]).to eq nomis_offender_number
    end
  end
end
