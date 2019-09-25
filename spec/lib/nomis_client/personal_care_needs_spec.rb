# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::PersonalCareNeeds, with_nomis_client_authentication: true do
  describe '.get' do
    let(:booking_number) { 321 }
    let(:response) { described_class.get(booking_number) }
    let(:client_response) do
      [
        {
          problem_type: 'MATSTAT',
          problem_code: 'ACCU9',
          problem_status: 'ON',
          problem_description: 'Preg, acc under 9mths',
          start_date: '2010-06-21',
          end_date: '2010-06-21'
        }
      ]
    end

    context 'when a resource is found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis_get_personal_care_needs_200.json').read }

      it 'returns the correct person data' do
        expect(response.map(&:symbolize_keys)).to eq client_response
      end
    end
  end
end
