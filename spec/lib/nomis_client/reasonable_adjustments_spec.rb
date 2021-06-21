# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::ReasonableAdjustments, with_nomis_client_authentication: true do
  describe '.get' do
    let(:booking_id) { 321 }
    let(:reasonable_adjustment_types) { 'DA,LEARN SUPP' }
    let(:response) { described_class.get(booking_id: booking_id, reasonable_adjustment_types: reasonable_adjustment_types) }
    let(:client_response) do
      [
        {
          treatment_code: 'DA',
          comment_text: 'Some comment text about DA',
          start_date: '2016-11-25',
          end_date: nil,
          agency_id: 'LGI',
          treatment_description: 'Some treatment description about DA',
        },
        {
          treatment_code: 'LEARN SUPP',
          comment_text: 'Some comment text about LEARN SUPP',
          start_date: '2020-04-01',
          end_date: '2020-05-01',
          agency_id: 'WYI',
          treatment_description: 'Some treatment description about LEARN SUPP',
        },
      ]
    end

    context 'when a resource is found' do
      context 'with a non-empty body' do
        let(:response_body) { file_fixture('nomis/get_reasonable_adjustments_200.json').read }

        it 'returns the correct person data' do
          expect(response.map(&:symbolize_keys)).to eq(client_response)
        end
      end

      context 'with an empty response body' do
        let(:response_body) { { 'reasonableAdjustments' => [] }.to_json }

        it 'returns an empty array' do
          expect(response).to eq([])
        end
      end
    end

    context 'with no reasonable adjustment types' do
      let(:reasonable_adjustment_types) { nil }

      it 'returns an empty array' do
        expect(response).to eq([])
      end
    end

    context 'with no booking id' do
      let(:booking_id) { nil }

      it 'returns an empty array' do
        expect(response).to eq([])
      end
    end
  end
end
