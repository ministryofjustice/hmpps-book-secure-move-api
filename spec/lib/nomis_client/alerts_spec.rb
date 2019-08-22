# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Alerts, with_nomis_client_authentication: true do
  describe '.get' do
    let(:prison_number) { 'G3239GV' }
    let(:response) { described_class.get(prison_number) }
    let(:client_response) do
      [
        {
          alertId: 2,
          alertType: 'X',
          alertTypeDescription: 'Security',
          alertCode: 'XVL',
          alertCodeDescription: 'Violent',
          comment: 'SIR GP162/11 17/01/11 - threatening to take staff hostage',
          dateCreated: '2013-03-29',
          dateExpires: '2018-06-08',
          expired: true,
          active: false,
          addedByFirstName: 'BOB',
          addedByLastName: 'ROBERTS',
          expiredByFirstName: 'ALICE',
          expiredByLastName: 'ROBERTS',
          rnum: 9
        },
        {
          alertId: 11,
          alertType: 'X',
          alertTypeDescription: 'Security',
          alertCode: 'XB',
          alertCodeDescription: 'Bully',
          comment: 'PLACED ON ZT2 MONITORING FOR THREATS TO ASSAULT HIS ASSAILANTS.',
          dateCreated: '2015-11-21',
          dateExpires: '2019-01-07',
          expired: false,
          active: true,
          addedByFirstName: 'BILLY',
          addedByLastName: 'ROBERTS',
          expiredByFirstName: 'CHARLIE',
          expiredByLastName: 'ROBERTS',
          rnum: 10
        }
      ]
    end

    context 'when a resource is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis_get_alerts_200.json').read }

      it 'returns the correct person data' do
        expect(response.map(&:symbolize_keys)).to eq client_response
      end
    end
  end
end
