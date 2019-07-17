# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Genders, with_nomis_client_authentication: true do
  describe '.get' do
    let(:response) { described_class.get }
    let(:api_endpoint) { '/reference-domains/domains/ETHNICITY' }

    context 'when a resource is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis_get_genders_200.json').read }

      it 'has the correct number of results' do
        expect(response.count).to be 4
      end

      it 'returns the correct data for the first match' do
        expect(response.first.symbolize_keys).to eq(key: 'F', title: 'Female')
      end

      it 'does not return inactive items' do
        expect(response.select { |item| item[:key] == 'REF' }.count).to be_zero
      end
    end
  end
end
