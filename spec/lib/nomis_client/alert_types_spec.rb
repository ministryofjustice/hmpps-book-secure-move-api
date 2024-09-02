# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::AlertTypes, :with_nomis_client_authentication do
  describe '.get' do
    let(:response) { described_class.get }
    let(:client_response) do
      [
        {
          active_flag: 'Y',
          code: 'A',
          description: 'Social Care',
          domain: 'ALERT',
          parent_code: nil,
          parent_domain: nil,
        },
        {
          active_flag: 'Y',
          code: 'C',
          description: 'Child Communication Measures',
          domain: 'ALERT',
          parent_code: nil,
          parent_domain: nil,
        },
      ]
    end

    context 'when a resource is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/get_alert_types_200.json').read }

      it 'returns the correct alert type data' do
        expect(response.map(&:symbolize_keys)).to eq client_response
      end
    end
  end

  describe '.as_hash' do
    let(:response) { described_class.as_hash }
    let(:client_response) do
      {
        A: {
          active_flag: 'Y',
          code: 'A',
          description: 'Social Care',
          domain: 'ALERT',
          parent_code: nil,
          parent_domain: nil,
        },
        C: {
          active_flag: 'Y',
          code: 'C',
          description: 'Child Communication Measures',
          domain: 'ALERT',
          parent_code: nil,
          parent_domain: nil,
        },
      }
    end

    context 'when a resource is found' do
      let(:response) { described_class.as_hash }
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/get_alert_types_200.json').read }

      it 'returns the correct alert type data' do
        expect(response.deep_symbolize_keys).to eq client_response
      end
    end
  end
end
