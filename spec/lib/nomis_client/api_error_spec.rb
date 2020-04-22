# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::ApiError do
  it '#to_json_api_errorjson' do
    nomis_error = described_class.new(status: 400, error_body: {
        'userMessage' => 'User message.', 'developerMessage' => 'Developer message.', 'moreInfo' => 'More info.'
    }.to_json)

    expect(nomis_error.json_api_error).to eq(code: 'NOMIS-ERROR',
                                             status: 400, title: 'User message.',
                                             details: 'Developer message. More info.')
  end
end
