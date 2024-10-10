# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlertsApiClient::AlertTypes, :with_nomis_client_authentication do
  describe '.get' do
    let(:response) { described_class.get }
    let(:client_response) do
      [
        {
          active_flag: true,
          code: 'BECTER',
          description: 'End Of Custody Temporary Release',
          type_code: 'B',
          type_description: 'End of Custody Temporary Release',
        },
        {
          active_flag: true,
          code: 'ECA',
          description: 'Exempt to receive cash',
          type_code: 'E',
          type_description: 'Financial Exemption',
        },
        {
          active_flag: true,
          code: 'ECA2',
          description: 'Exempt to receive cash 2',
          type_code: 'E',
          type_description: 'Financial Exemption',
        },
      ]
    end

    context 'when a resource is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('alerts_api/get_alert_types_200.json').read }

      it 'returns the correct alert type data' do
        expect(response.map(&:symbolize_keys)).to eq client_response
      end
    end
  end
end
