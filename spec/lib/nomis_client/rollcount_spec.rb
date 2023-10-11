# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Rollcount, with_nomis_client_authentication: true do
  describe '.get' do
    let(:response) { described_class.get(agency_id:, unassigned:) }
    let(:agency_id) { 'PRI' }
    let(:unassigned) { true }

    context 'when a resource is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/get_rollcount_200.json').read }

      it 'has the correct number of results' do
        expect(response.count).to be 5
      end

      it 'returns the correct data' do
        expect(response.first.symbolize_keys).to eq({
          availablePhysical: 367,
          bedsInUse: 33,
          currentlyInCell: 2,
          currentlyOut: 31,
          livingUnitDesc: 'COURT',
          livingUnitId: 8839,
          maximumCapacity: 400,
          outOfOrder: 0,
        })
      end
    end
  end
end
