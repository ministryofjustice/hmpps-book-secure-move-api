# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Locations, :with_nomis_client_authentication do
  describe '.get' do
    let(:response) { described_class.get }
    let(:api_endpoint) { '/agencies' }
    let(:response_status) { 200 }
    let(:response_body) { file_fixture('nomis/get_locations_200.json').read }

    it 'has the correct number of results' do
      expect(response.count).to eq 12
    end

    it 'returns POLICE agencies' do
      expect(response.first)
        .to include(key: '218434', nomis_agency_id: '218434', title: 'Test Police Custody', location_type: 'police')
    end

    it 'returns the correct data for the first COURT match' do
      expect(response[3])
        .to eq(key: 'abdrct', nomis_agency_id: 'ABDRCT', title: 'Aberdare County Court', location_type: 'court', can_upload_documents: false)
    end

    it 'returns the correct data for the first HOSPITAL match' do
      expect(response[11])
          .to eq(key: 'hosp1', nomis_agency_id: 'HOSP1', title: 'An example hospital', location_type: 'hospital', can_upload_documents: false)
    end

    it 'does not return locations with unwanted agency types' do
      expect(response.select { |item| item[:nomis_agency_id] == 'DRRPROV' }.count).to be_zero
    end

    it 'sets can_upload_documents for an STC' do
      expect(response.detect { |item| item[:nomis_agency_id] == 'STC1' }.fetch(:can_upload_documents)).to be(true)
    end

    it 'sets can_upload_documents for an SCH' do
      expect(response.detect { |item| item[:nomis_agency_id] == 'SCH1' }.fetch(:can_upload_documents)).to be(true)
    end
  end
end
