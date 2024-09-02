# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Alerts, :with_nomis_client_authentication do
  describe '.get' do
    let(:prison_numbers) { %w[G3239GV A8348EC] }
    let(:response) { described_class.get(prison_numbers) }
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
          offender_no: 'A9127EK',
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
          offender_no: 'C9127XK',
        },
      ]
    end

    context 'when a resource is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/post_alerts_200.json').read }

      it 'returns the correct person data' do
        expect(response.map(&:symbolize_keys)).to eq client_response
      end
    end
  end
end
