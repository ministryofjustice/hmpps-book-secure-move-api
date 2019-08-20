# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Moves, with_nomis_client_authentication: true do
  describe '.get' do
    let(:nomis_agency_id) { 'BXI' }
    let(:date) { Date.parse('2019-08-19') }
    let(:response) { described_class.get(nomis_agency_id, date) }
    let(:client_response) do
      [
        {
          person_nomis_prison_number: 'G3239GV',
          from_location_nomis_agency_id: 'BXI',
          to_location_nomis_agency_id: 'BXI',
          date: '2019-08-19',
          time_due: '17:00:00',
          nomis_event_id: 468_536_961
        },
        {
          person_nomis_prison_number: 'G7157AB',
          from_location_nomis_agency_id: 'BXI',
          to_location_nomis_agency_id: 'WDGRCC',
          date: '2019-08-19',
          time_due: '09:00:00',
          nomis_event_id: 487_463_210
        }
      ]
    end

    context 'when results are presnt' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis_get_moves_200.json').read }

      it 'returns the correct moves data' do
        expect(response).to eq client_response
      end
    end
  end
end
