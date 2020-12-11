# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisCourtHearing do
  describe '#build_from_nomis' do
    subject(:court_hearing) { described_class.new }

    let(:nomis_court_hearing) do
      {
        'id' => 330_253_339,
        'dateTime' => '2017-01-27T10:00:00',
        'location' => {
          'agencyId' => 'SNARCC',
          'description' => 'Snaresbrook Crown Court',
          'agencyType' => 'CRT',
          'active' => true,
        },
      }
    end
    let(:expected_attributes) do
      {
        id: nomis_court_hearing['id'],
        start_time: Time.zone.parse(nomis_court_hearing['dateTime']),
        type: 'Court',
        reason: 'Court appearance',
        agency_id: nomis_court_hearing['location']['agencyId'],
      }
    end

    it { expect(court_hearing.build_from_nomis(nomis_court_hearing)).to be_a(described_class) }
    it { expect(court_hearing.build_from_nomis(nomis_court_hearing)).to have_attributes(expected_attributes) }
  end
end
