# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Ethnicities, :with_hmpps_authentication do
  describe '.get' do
    let(:response) { described_class.get }
    let(:api_endpoint) { '/reference-domains/domains/ETHNICITY' }
    let(:response_status) { 200 }
    let(:response_body) { file_fixture('nomis/get_ethnicities_200.json').read }

    it 'has the correct number of results' do
      expect(response.count).to be 20
    end

    it 'returns the correct data for the first match' do
      expect(response.first).to eq(key: 'a1', nomis_code: 'A1', title: 'Asian/Asian British: Indian')
    end

    it 'does not return inactive items' do
      expect(response.select { |item| item[:key] == 'w8' }.count).to be_zero
    end
  end
end
