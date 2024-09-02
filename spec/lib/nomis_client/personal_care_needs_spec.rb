# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::PersonalCareNeeds, :with_nomis_client_authentication do
  describe '.get' do
    let(:nomis_offender_numbers) { [321, 123] }
    let(:response) { described_class.get(nomis_offender_numbers:) }
    let(:client_response) do
      [
        {
          problem_type: 'MATSTAT',
          problem_code: 'ACCU9',
          problem_status: 'ON',
          problem_description: 'Preg, acc under 9mths',
          start_date: '2010-06-21',
          end_date: '2010-06-21',
          offender_no: '321',
          commentText: 'Disclosed on arrival',
        },
        {
          problem_type: 'MATSTAT',
          problem_code: 'ACCV4',
          problem_status: 'ON',
          problem_description: 'Preg, acc under 9mths',
          start_date: '2010-06-22',
          end_date: '2010-06-22',
          offender_no: '123',
          commentText: 'Disclosed on arrival',
        },
      ]
    end

    context 'when a resource is found' do
      let(:response_status) { 200 }

      context 'with a non-empty body' do
        let(:response_body) { file_fixture('nomis/post_personal_care_needs_200.json').read }

        it 'returns the correct person data' do
          expect(response.map(&:symbolize_keys)).to eq client_response
        end
      end

      context 'with an empty response body' do
        let(:response_body) { [].to_json }

        it 'returns an empty array' do
          expect(response).to eq([])
        end
      end
    end
  end
end
