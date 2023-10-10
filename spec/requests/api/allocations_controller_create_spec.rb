# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::AllocationsController do
  include ActiveJob::TestHelper

  let(:response_json) { JSON.parse(response.body) }
  let(:resource_to_json) do
    resource = JSON.parse(AllocationSerializer.new(allocation).serializable_hash.to_json)
    resource['data']['relationships']['moves']['data'] = UnorderedArray(*resource.dig('data', 'relationships', 'moves', 'data'))
    resource
  end

  describe 'POST /allocations' do
    subject(:post_allocations) { post '/api/v1/allocations', params: { data: }, headers:, as: :json }

    let(:schema) { load_yaml_schema('post_allocations_responses.yaml') }

    let(:complex_case1_attributes) do
      {
        key: complex_case1.key,
        title: complex_case1.title,
        answer: false,
        allocation_complex_case_id: complex_case1.id,
      }
    end
    let(:complex_case2_attributes) do
      {
        key: complex_case2.key,
        title: complex_case2.title,
        answer: true,
        allocation_complex_case_id: complex_case2.id,
      }
    end
    let(:complex_cases_attributes) do
      [
        complex_case1_attributes,
        complex_case2_attributes,
      ]
    end
    let(:moves_count) { 2 }
    let(:allocation_attributes) do
      {
        date: Time.zone.today,
        moves_count:,
        estate: :other_estate,
        estate_comment: 'Another estate description',
        prisoner_category: :b,
        sentence_length: :other,
        sentence_length_comment: '30 years',
        other_criteria: 'curly hair',
        requested_by: 'Iama Requestor',
        complete_in_full: true,
        complex_cases: complex_cases_attributes,
      }
    end

    let!(:from_location) { create :location, suppliers: [supplier] }
    let!(:to_location) { create :location }
    let!(:complex_case1) { create :allocation_complex_case }
    let!(:complex_case2) { create :allocation_complex_case, :self_harm }

    let(:data) do
      {
        type: 'allocations',
        attributes: allocation_attributes,
        relationships: {
          from_location: { data: { type: 'locations', id: from_location.id } },
          to_location: { data: { type: 'locations', id: to_location.id } },
        },
      }
    end

    let(:supplier) { create(:supplier) }
    let(:access_token) { 'spoofed-token' }
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
    let(:content_type) { ApiController::CONTENT_TYPE }

    context 'when successful' do
      before { post_allocations }

      it_behaves_like 'an endpoint that responds with success 201'
    end

    describe 'creating allocations' do
      let(:allocation) { Allocation.find_by(from_location_id: from_location.id) }

      it 'creates an allocation' do
        expect { post_allocations }.to change(Allocation, :count).by(1)
      end

      it 'sets the from_location supplier as the supplier on the move' do
        post_allocations
        expect(allocation.moves.pluck(:supplier_id).uniq).to contain_exactly(from_location.suppliers.first.id)
      end

      context 'with a real access token' do
        let(:application) { create(:application, owner: supplier) }
        let(:access_token) { create(:access_token, application:).token }

        it 'audits the supplier' do
          post_allocations
          expect(allocation.versions.map(&:whodunnit)).to eq([nil])
          expect(allocation.versions.map(&:supplier_id)).to eq([supplier.id])
        end

        it 'sets the application owner as the supplier on allocation moves' do
          post_allocations
          expect(allocation.moves.pluck(:supplier_id).uniq).to contain_exactly(supplier.id)
        end
      end

      it 'returns the correct data' do
        post_allocations
        expect(response_json).to include_json resource_to_json
      end

      context 'when the supplier has a webhook subscription' do
        let!(:subscription) { create(:subscription, :no_email_address, supplier:) }
        let!(:notification_type_webhook) { create(:notification_type, :webhook) }
        let(:notification) { subscription.notifications.last }
        let(:faraday_client) do
          class_double(
            Faraday,
            headers: {},
            post:
                        instance_double(Faraday::Response, success?: true, status: 202),
          )
        end

        before do
          allow(Faraday).to receive(:new).and_return(faraday_client)
          perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
            post_allocations
          end
        end

        it 'enqueues a notification for each move created' do
          expect(subscription.notifications.count).to eq(2)
        end

        describe 'notification record' do
          let(:moves_count) { 1 }

          it 'has correct attributes' do
            expect(notification).to have_attributes(
              delivered_at: a_value,
              topic: allocation.moves.last,
              notification_type: notification_type_webhook,
              event_type: 'create_move',
              response_id: nil,
            )
          end
        end
      end

      context 'when the supplier has an email subscription', :skip_before do
        let!(:subscription) { create(:subscription, :no_callback_url, supplier:) }
        let!(:notification_type_email) { create(:notification_type, :email) }
        let(:notification) { subscription.notifications.last }
        let(:notify_response) do
          instance_double(
            ActionMailer::MessageDelivery,
            deliver_now!:
                          instance_double(
                            Mail::Message,
                            govuk_notify_response:
                                              instance_double(Notifications::Client::ResponseNotification, id: response_id),
                          ),
          )
        end
        let(:response_id) { SecureRandom.uuid }

        before do
          allow(MoveMailer).to receive(:notify).and_return(notify_response)
          perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyEmailJob]) do
            post_allocations
          end
        end

        it 'enqueues a notification for each move created' do
          expect(subscription.notifications.count).to eq(2)
        end

        describe 'notification record' do
          let(:moves_count) { 1 }

          it 'has correct attributes' do
            expect(notification).to have_attributes(
              delivered_at: a_value,
              topic: allocation.moves.last,
              notification_type: notification_type_email,
              event_type: 'create_move',
              response_id:,
            )
          end
        end
      end
    end

    context 'with a bad request' do
      let(:data) { nil }

      before { post_allocations }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with a reference to a missing relationship' do
      let(:from_location) { Location.new }
      let(:detail_404) { "Couldn't find Location without an ID" }

      before { post_allocations }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with validation errors' do
      let(:allocation_attributes) { attributes_for(:allocation).except(:date) }

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

      before { post_allocations }

      it_behaves_like 'an endpoint that responds with error 422'
    end
  end
end
