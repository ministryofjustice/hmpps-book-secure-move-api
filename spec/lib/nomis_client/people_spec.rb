# frozen_string_literal: true

require 'rails_helper'
require 'nomis_client/moves'
require 'dotenv/load'

RSpec.describe NomisClient::People do
  describe '.get' do
    let(:response) { described_class.get }

    it 'has the correct number of results' do
      VCR.use_cassette('people', record: :new_episodes) do
        expect(response.count).to be 1
      end
    end
  end

  describe '.anonymise' do
    before do
      create :location, title: 'PENTONVILLE (HMP)', nomis_agency_id: 'PVI'
      create :location, title: 'LEEDS (HMP)', nomis_agency_id: 'LEI'
      create :location, title: 'MANCHESTER (HMP)', nomis_agency_id: 'MRI'
    end

    KEYS = %i[
      offenderNo firstName middleNames lastName dateOfBirth gender sexCode nationalities
      currentlyInPrison latestBookingId latestLocationId latestLocation internalLocation
      pncNumber croNumber ethnicity birthCountry religion convictedStatus
      imprisonmentStatus maritalStatus
    ].freeze
    let(:anonymised) { described_class.anonymise(nil) }

    KEYS.each do |key|
      it "randomly populates the #{key}" do
        expect(anonymised).to have_key(key)
      end
    end
  end
end
