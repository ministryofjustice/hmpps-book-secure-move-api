# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::ApiError do
  describe '#json_api_error' do
    subject(:error) { described_class.new(status:, error_body:) }

    let(:status) { 400 }

    let(:error_body) do
      {
        'userMessage' => 'User message.',
        'developerMessage' => 'Developer message.',
        'moreInfo' => 'More info.',
      }.to_json
    end

    it 'returns a properly formatted api error' do
      expect(error.json_api_error).to eq(
        code: 'NOMIS-ERROR',
        status: 400,
        title: 'User message.',
        details: 'Developer message. More info.',
      )
    end

    context 'when parsing the error_body raises a JSON::ParserError' do
      let(:error_body) { '<html></html>' }

      it 'returns a properly formatted api error' do
        expect(error.json_api_error).to eq(
          code: 'NOMIS-ERROR',
          status: 400,
          title: 'Unparseable error from Nomis',
          details: "Status #{status}. We tried to parse an error from Nomis and failed. Is the Elite2API routeable?",
        )
      end
    end
  end
end
