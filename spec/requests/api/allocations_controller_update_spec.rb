# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::AllocationsController do
  include ActiveJob::TestHelper

  let(:response_json) { JSON.parse(response.body) }

  let(:resource_to_json) do
    resource = JSON.parse(AllocationSerializer.new(allocation.reload).serializable_hash.to_json)
    resource['data']['relationships']['moves']['data'] = UnorderedArray(*resource.dig('data', 'relationships', 'moves', 'data'))
    resource
  end

  describe 'PATCH /allocations' do
    subject(:patch_allocations) do
      patch "/api/allocations/#{allocation.id}", params: { data: data }, headers: headers, as: :json
    end

    let(:schema) { load_yaml_schema('patch_allocation_responses.yaml') }
    let(:moves_count) { 2 }
    let(:access_token) { 'spoofed-token' }
    let(:content_type) { ApiController::CONTENT_TYPE }
    let(:headers) { { 'Authorization' => "Bearer #{access_token}", 'CONTENT_TYPE': content_type } }
    let(:existing_date) { Date.new(2023, 1, 1) }
    let(:new_date) { existing_date.tomorrow }
    let!(:allocation) { create(:allocation, date: existing_date, moves_count: moves_count) }
    let!(:moves) { create_list(:move, moves_count, allocation: allocation, date: existing_date, person: create(:person)) }

    let(:allocation_attributes) { { date: new_date } }

    let(:data) do
      {
        type: 'allocations',
        attributes: allocation_attributes,
      }
    end

    context 'when successful' do
      before { patch_allocations }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'updates the allocation date' do
        expect(allocation.reload.date).to eq(new_date)
      end

      it 'returns the correct data' do
        expect(response_json).to include_json resource_to_json
      end

      it 'updates the date of all of the moves' do
        expect(allocation.reload.moves.pluck(:date).uniq).to eq([new_date])
      end
    end

    context 'with no moves' do
      let!(:moves) { [] } # rubocop:disable RSpec/LetSetup

      before { patch_allocations }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'updates the allocation date' do
        expect(allocation.reload.date).to eq(new_date)
      end

      it 'returns the correct data' do
        expect(response_json).to include_json resource_to_json
      end
    end

    context 'with an invalid date' do
      let(:new_date) { nil }

      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => "Date can't be blank",
            'source' => { 'pointer' => '/data/attributes/date' },
            'code' => 'blank',
          },
        ]
      end

      before { patch_allocations }

      it_behaves_like 'an endpoint that responds with error 422'

      it 'does not update the allocation date' do
        expect(allocation.reload.date).to eq(existing_date)
      end

      it 'does not update the date of any of the moves' do
        expect(allocation.reload.moves.pluck(:date).uniq).to eq([existing_date])
      end
    end

    context 'with a param that is not permitted' do
      let(:allocation_attributes) { { moves_count: 7 } }

      before { patch_allocations }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'does not update the moves count' do
        expect(allocation.reload.moves_count).to eq(2)
      end

      it 'returns the correct data' do
        expect(response_json).to include_json resource_to_json
      end
    end

    context 'when one of the moves would be a duplicate if updated' do
      before do
        create(
          :move,
          profile: moves.last.profile,
          date: new_date,
          from_location: moves.last.from_location,
          to_location: moves.last.to_location,
        )
        patch_allocations
      end

      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => 'Date has already been taken',
            'source' => { 'pointer' => '/data/attributes/date' },
            'code' => 'taken',
          },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422'

      it 'does not update the allocation date' do
        expect(allocation.reload.date).to eq(existing_date)
      end

      it 'does not update the date of any of the moves' do
        expect(allocation.reload.moves.pluck(:date).uniq).to eq([existing_date])
      end
    end
  end
end
