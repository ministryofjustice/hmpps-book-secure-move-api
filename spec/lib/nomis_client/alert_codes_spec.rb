# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::AlertCodes, :with_nomis_client_authentication do
  describe '.get' do
    let(:response) { described_class.get }
    let(:client_response) do
      [
        {
          active_flag: nil,
          code: 'AAR',
          description: 'Adult At Risk (Home Office identified)',
          domain: 'ALERT_CODE',
          parent_code: nil,
          parent_domain: nil,
        },
        {
          active_flag: nil,
          code: 'AS',
          description: 'Social Care',
          domain: 'ALERT_CODE',
          parent_code: nil,
          parent_domain: nil,
        },
        {
          active_flag: nil,
          code: 'C1',
          description: 'L1 Restriction No contact with any child',
          domain: 'ALERT_CODE',
          parent_code: nil,
          parent_domain: nil,
        },
        {
          active_flag: nil,
          code: 'C2',
          description: 'L2 Written Contact with Children only',
          domain: 'ALERT_CODE',
          parent_code: nil,
          parent_domain: nil,
        },
        {
          active_flag: nil,
          code: 'C3',
          description: 'L3 Monitored Contact written or phone',
          domain: 'ALERT_CODE',
          parent_code: nil,
          parent_domain: nil,
        },
      ]
    end

    context 'when a resource is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/get_alert_codes_200.json').read }

      it 'returns the correct alert code data' do
        expect(response.map(&:symbolize_keys)).to eq client_response
      end
    end
  end
end
