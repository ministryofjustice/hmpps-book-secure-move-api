# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlertsApiClient::Alerts, :with_nomis_client_authentication do
  describe '.get' do
    let(:prison_number) { 'G3239GV' }
    let(:response) { described_class.get(prison_number) }

    context 'when there are two alerts' do
      let(:client_response) do
        [
          {
            alert_id: '2683f679-113a-469d-993f-01a75f06f904',
            alert_type: 'X',
            alert_type_description: 'Security',
            alert_code: 'XCDO',
            alert_code_description: 'Involved in 2024 civil disorder',
            comment: '',
            created_at: '2024-10-07T12:10:32',
            expires_at: nil,
            expired: false,
            active: true,
            prison_number: 'G1618UI',
          },
          {
            alert_id: '2dd3faee-4b61-442a-9b6a-b89798a2bd00',
            alert_type: 'X',
            alert_type_description: 'Security',
            alert_code: 'XA',
            alert_code_description: 'Arsonist',
            comment: '',
            created_at: '2024-09-05T17:21:25',
            expires_at: nil,
            expired: false,
            active: true,
            prison_number: 'G1618UI',
          },
        ]
      end

      let(:response_status) { 200 }
      let(:response_body) { file_fixture('alerts_api/get_alerts_200.json').read }

      it 'returns the expected alerts' do
        expect(response.map(&:symbolize_keys)).to eq client_response
      end
    end
  end
end
