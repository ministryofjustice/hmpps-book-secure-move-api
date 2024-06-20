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

  let(:envs) { { FEATURE_FLAG_CROSS_SUPPLIER_NOTIFICATIONS_SUPPLIERS: 'geoamey,serco' } }

  around do |example|
    ClimateControl.modify(**envs) do
      example.run
    end
  end

  describe 'PATCH /allocations' do
    subject(:patch_allocations) do
      patch "/api/allocations/#{allocation.id}", params: { data: }, headers:, as: :json
    end

    let(:schema) { load_yaml_schema('patch_allocation_responses.yaml') }
    let(:moves_count) { 2 }
    let(:access_token) { 'spoofed-token' }
    let(:content_type) { ApiController::CONTENT_TYPE }
    let(:headers) { { 'Authorization' => "Bearer #{access_token}", 'CONTENT_TYPE': content_type } }
    let(:existing_date) { Date.new(2023, 1, 1) }
    let(:new_date) { existing_date.tomorrow }
    let(:supplier) { create(:supplier, :serco) }
    let!(:allocation) { create(:allocation, date: existing_date, moves_count:) }
    let!(:moves) { create_list(:move, moves_count, allocation:, date: existing_date, person: create(:person), supplier:) }

    let(:allocation_attributes) { { date: new_date } }

    let(:data) do
      {
        type: 'allocations',
        attributes: allocation_attributes,
      }
    end

    shared_context 'when the supplier has a webhook subscription' do
      let!(:subscription) { create(:subscription, :no_email_address, supplier:) }

      let(:faraday_client) do
        class_double(
          Faraday,
          headers: {},
          post: instance_double(Faraday::Response, success?: true, status: 202),
        )
      end

      before do
        create(:notification_type, :webhook)
        allow(Faraday).to receive(:new).and_return(faraday_client)
      end
    end

    shared_examples 'notifications created' do
      include_context 'when the supplier has a webhook subscription'

      it 'creates notifications for each move' do
        perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
          expect { patch_allocations }
            .to change { subscription.notifications.count }
            .by(2)
        end
      end
    end

    shared_examples 'notifications not created' do
      include_context 'when the supplier has a webhook subscription'

      it 'does not create notifications for each move' do
        perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
          expect { patch_allocations }
            .not_to(change { subscription.notifications.where(event_type: 'update_move').count })
        end
      end
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200' do
        before { patch_allocations }
      end

      it 'updates the allocation date' do
        patch_allocations
        expect(allocation.reload.date).to eq(new_date)
      end

      it 'returns the correct data' do
        patch_allocations
        expect(response_json).to include_json resource_to_json
      end

      it 'updates the date of all of the moves' do
        patch_allocations
        expect(allocation.reload.moves.pluck(:date).uniq).to eq([new_date])
      end

      it 'creates GenericEvent::MoveDateChanged events' do
        patch_allocations
        expect(GenericEvent.where(type: 'GenericEvent::MoveDateChanged').pluck('details'))
          .to eq([{ 'date' => '2023-01-02' }, { 'date' => '2023-01-02' }])
      end

      it_behaves_like 'notifications created'
    end

    context 'with no moves' do
      let!(:moves) { [] }

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

      it_behaves_like 'an endpoint that responds with error 422' do
        before { patch_allocations }
      end

      it 'does not update the allocation date' do
        patch_allocations
        expect(allocation.reload.date).to eq(existing_date)
      end

      it 'does not update the date of any of the moves' do
        patch_allocations
        expect(allocation.reload.moves.pluck(:date).uniq).to eq([existing_date])
      end

      it_behaves_like 'notifications not created'
    end

    context 'when the allocation fails to save' do
      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => 'Moves count is invalid',
            'source' => { 'pointer' => '/data/attributes/moves_count' },
            'code' => 'invalid',
          },
        ]
      end

      before do
        allocation.errors.add(:moves_count)

        allow_any_instance_of(Allocation) # rubocop:disable RSpec/AnyInstance
          .to receive(:save!)
          .and_raise(ActiveRecord::RecordInvalid.new(allocation))
      end

      it_behaves_like 'an endpoint that responds with error 422' do
        before { patch_allocations }
      end

      it 'does not update the allocation date' do
        patch_allocations
        expect(allocation.reload.date).to eq(existing_date)
      end

      it 'does not update the date of any of the moves' do
        patch_allocations
        expect(allocation.reload.moves.pluck(:date).uniq).to eq([existing_date])
      end

      it_behaves_like 'notifications not created'
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

      it_behaves_like 'an endpoint that responds with error 422' do
        before { patch_allocations }
      end

      it 'does not update the allocation date' do
        patch_allocations
        expect(allocation.reload.date).to eq(existing_date)
      end

      it 'does not update the date of any of the moves' do
        patch_allocations
        expect(allocation.reload.moves.pluck(:date).uniq).to eq([existing_date])
      end

      it_behaves_like 'notifications not created'
    end
  end
end
