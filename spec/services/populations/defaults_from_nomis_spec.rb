# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Populations::DefaultsFromNomis, :with_hmpps_authentication do
  subject(:defaults) { described_class.call(location, date) }

  let(:agency_id) { 'PRI' }
  let(:location) { create(:location, :prison, nomis_agency_id: agency_id) }
  let(:date) { Time.zone.today }

  let(:all_cells) do
    {
      'totals' => { 'currentlyInCell' => 8 },
    }
  end
  let(:movements) { { 'in' => 10, 'out' => 5 } }
  let(:discharges) do
    [
      { 'firstName': 'Test' },
      { 'firstName': 'Test1' },
    ]
  end

  before do
    allow(NomisClient::Rollcount).to receive(:get).with(agency_id:).and_return(all_cells)
    allow(NomisClient::Movements).to receive(:get).with(agency_id:, date:).and_return(movements)
    allow(NomisClient::Discharges).to receive(:get).with(agency_id:, date:).and_return(discharges)
  end

  context 'with correct details from Nomis' do
    it 'returns correct unlock and discharges' do
      expect(defaults).to eq({
        unlock: 3 + 4 + 1 - 10 + 2,
        discharges: 2,
      })
    end
  end

  context 'with missing rollcount details from Nomis' do
    let(:all_cells) { nil }

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
    let(:all_cells) { nil }
    let(:movements) { nil }
    let(:discharges) { nil }

    it 'returns empty hash' do
      expect(defaults).to be_empty
    end
  end
end
