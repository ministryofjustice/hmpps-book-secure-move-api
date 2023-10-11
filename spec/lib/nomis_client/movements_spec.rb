# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Movements, with_nomis_client_authentication: true do
  describe '.get' do
    let(:response) { described_class.get(agency_id:, date:) }
    let(:date) { Time.zone.today }
    let(:agency_id) { 'PRI' }

    context 'when a resource is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/get_movements_200.json').read }

      it 'returns the correct data' do
        expect(response.symbolize_keys).to eq(in: 10, out: 5)
      end
    end
  end
end
