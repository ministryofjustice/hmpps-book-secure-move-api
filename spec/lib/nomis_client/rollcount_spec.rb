# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Rollcount, with_nomis_client_authentication: true do
  describe '.get' do
    let(:response) { described_class.get(agency_id:) }
    let(:agency_id) { 'PRI' }

    context 'when a resource is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/get_rollcount_200.json').read }

      it 'returns the correct data' do
        expect(response.symbolize_keys).to eq({
          prisonId: 'PRI',
          numUnlockRollToday: 0,
          numCurrentPopulation: 97,
          numArrivedToday: 0,
          numInReception: 0,
          numStillToArrive: 0,
          numOutToday: 0,
          numNoCellAllocated: 0,
          totals: {
            "bedsInUse" => 53,
            "currentlyInCell" => 7,
            "currentlyOut" => 44,
            "workingCapacity" => 0,
            "netVacancies" => 0,
            "outOfOrder" => 0,
          },
        })
      end
    end
  end
end
