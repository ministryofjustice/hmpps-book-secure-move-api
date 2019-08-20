# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::People, with_nomis_client_authentication: true do
  describe '.get' do
    let(:prison_number) { 'G3239GV' }
    let(:response) { described_class.get(prison_number) }
    let(:client_response) do
      {
        prison_number: 'G3239GV',
        last_name: 'ABBELLA',
        first_name: 'AVEILKE',
        middle_names: 'EMMANDA',
        date_of_birth: '1965-10-15',
        aliases: nil,
        pnc_number: '82/18053V',
        cro_number: '018053/82G',
        gender: 'M',
        ethnicity: 'White: Eng./Welsh/Scot./N.Irish/British',
        nationalities: 'British'
      }
    end

    context 'when a resource is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis_get_prisoner_200.json').read }

      it 'returns the correct person data' do
        expect(response).to eq client_response
      end
    end
  end
end
