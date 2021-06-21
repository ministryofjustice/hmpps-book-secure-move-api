# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Populations::DefaultsFromNomis, with_nomis_client_authentication: true do
  subject(:defaults) { described_class.call(location, date) }

  let(:agency_id) { 'PRI' }
  let(:location) { create(:location, :prison, nomis_agency_id: agency_id) }
  let(:date) { Date.today }

  let(:assigned_cells) do
    [
      { 'currentlyInCell' => 3 },
      { 'currentlyInCell' => 4 },
    ]
  end
  let(:unassigned_cells) do
    [
      { 'currentlyInCell' => 1 },
    ]
  end
  let(:movements) { { 'in' => 10, 'out' => 5 } }
  let(:discharges) do
    [
      { 'firstName': 'Test' },
      { 'firstName': 'Test1' },
    ]
  end

  before do
    allow(NomisClient::Rollcount).to receive(:get).with(agency_id: agency_id, unassigned: false).and_return(assigned_cells)
    allow(NomisClient::Rollcount).to receive(:get).with(agency_id: agency_id, unassigned: true).and_return(unassigned_cells)
    allow(NomisClient::Movements).to receive(:get).with(agency_id: agency_id, date: date).and_return(movements)
    allow(NomisClient::Discharges).to receive(:get).with(agency_id: agency_id, date: date).and_return(discharges)
  end

  context 'with correct details from Nomis' do
    it 'returns correct unlock and discharges' do
      expect(defaults).to eq({
        unlock: 3 + 4 + 1 - 10 + 2,
        discharges: 2,
      })
    end
  end

  context 'with blank rollcount details from Nomis' do
    let(:unassigned_cells) do
      [
        nil,
      ]
    end

    it 'returns correct unlock and discharges' do
      expect(defaults).to eq({
        unlock: 3 + 4 - 10 + 2,
        discharges: 2,
      })
    end
  end

  context 'with missing rollcount details from Nomis' do
    let(:assigned_cells) { nil }
    let(:unassigned_cells) { nil }

    it 'returns empty hash' do
      expect(defaults).to be_empty
    end
  end

  context 'with missing movement details from Nomis' do
    let(:movements) { nil }

    it 'returns empty hash' do
      expect(defaults).to be_empty
    end
  end

  context 'with missing rollcount and movement details from Nomis' do
    let(:assigned_cells) { nil }
    let(:unassigned_cells) { nil }
    let(:movements) { nil }
    let(:discharges) { nil }

    it 'returns empty hash' do
      expect(defaults).to be_empty
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
