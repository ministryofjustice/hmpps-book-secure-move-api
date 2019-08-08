# frozen_string_literal: true

require 'rails_helper'
require 'dotenv/load'

RSpec.describe NomisClient::Moves do
  describe '.get' do
    let(:date) { DateTime.civil(2019, 7, 8, 12, 23, 45) }
    let(:nomis_agency_ids) { 'LEI' }
    let(:response) { described_class.get(nomis_agency_ids: nomis_agency_ids, date: date) }

    it 'has the correct number of results' do
      VCR.use_cassette('moves') do
        expect(response.count).to be 4
      end
    end
  end
end
