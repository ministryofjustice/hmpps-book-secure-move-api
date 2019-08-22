# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Alerts, with_nomis_client_authentication: true do
  describe '.get' do
    let(:prison_number) { 'G3239GV' }
    let(:response) { described_class.get(prison_number) }
    let(:client_response) do
      [
        {
          alert_id: 2,
          alert_type: 'X',
          alert_type_description: 'Security',
          alert_code: 'XVL',
          alert_code_description: 'Violent',
          comment: 'SIR GP162/11 17/01/11 - threatening to take staff hostage',
          created_at: '2013-03-29',
          expires_at: '2018-06-08',
          expired: true,
          active: false,
          rnum: 9
        },
        {
          alert_id: 11,
          alert_type: 'X',
          alert_type_description: 'Security',
          alert_code: 'XB',
          alert_code_description: 'Bully',
          comment: 'PLACED ON ZT2 MONITORING FOR THREATS TO ASSAULT HIS ASSAILANTS.',
          created_at: '2015-11-21',
          expires_at: '2019-01-07',
          expired: false,
          active: true,
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
