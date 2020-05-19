# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController do
  include ActiveJob::TestHelper

  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }
  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: move.reload, include: MoveSerializer::INCLUDED_ATTRIBUTES))
  end

  let(:detail_404) { "Couldn't find Move with 'id'=UUID-not-found" }

  describe 'PATCH /moves' do
    let(:schema) { load_yaml_schema('patch_move_responses.yaml') }
    let(:supplier) { create(:supplier) }
    let!(:from_location) { create :location, suppliers: [supplier] }
    let(:profile) { create(:profile) }
    let!(:move) { create :move, :proposed, move_type: 'prison_recall', from_location: from_location, documents: before_documents, profile: profile }
    let(:move_id) { move.id }
    let(:date_from) { Date.yesterday }
    let(:date_to) { Date.tomorrow }
    let(:before_documents) { create_list(:document, 2) }

    let(:move_params) do
      {
        type: 'moves',
        attributes: {
          status: 'requested',
          additional_information: 'some more info',
          cancellation_reason: nil, # NB: cancellation_reason must only be specified if status==cancelled
          cancellation_reason_comment: nil,
          move_type: 'court_appearance',
          move_agreed: true,
          move_agreed_by: 'Fred Bloggs',
          date_from: date_from,
          date_to: date_to,
        },
      }
    end

    before do
      next if RSpec.current_example.metadata[:skip_before]

      do_patch
    end

    context 'when not authorized', :with_invalid_auth_headers do
      let(:detail_401) { 'Token expired or invalid' }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'when authorized' do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{token.token}") }
      let(:token) { create(:access_token) }

      context 'with an existing requested move', :skip_before do
        before do
          create(:move, :requested,
                 profile: profile,
                 from_location: move.from_location,
                 to_location: move.to_location,
                 date: move.date)
          do_patch
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
      end

      context 'when successful' do
        let(:result) { move.reload }

        it_behaves_like 'an endpoint that responds with success 200'

        it 'updates the status of a move' do
          expect(result.status).to eq 'requested'
        end

        it 'does not update the move type' do
          expect(result.move_type).to eq('prison_recall')
        end

        it 'updates move_agreed' do
          expect(result.move_agreed).to be true
        end

        it 'updates move_agreed_by' do
          expect(result.move_agreed_by).to eq 'Fred Bloggs'
        end

        it 'updates date_from' do
          expect(result.date_from).to eq date_from
        end

        it 'updates date_to' do
          expect(result.date_to).to eq date_to
        end
        it 'updates the additional_information of a move' do
          expect(result.additional_information).to eq 'some more info'
        end

        it 'does not update the cancellation_reason of a move' do
          expect(result.cancellation_reason).to be nil
        end

        it 'does not update the cancellation_reason_comment of a move' do
          expect(result.cancellation_reason_comment).to be nil
        end

        it 'returns the correct data' do
          expect(response_json).to eq resource_to_json
        end

        context 'when changing a moves documents', :skip_before do
          let(:after_documents) { create_list(:document, 2) }
          let(:move_params) do
            documents = after_documents.map { |d| { id: d.id, type: 'documents' } }
            {
              type: 'moves',
              attributes: {
                status: 'requested',
                additional_information: 'some more info',
                cancellation_reason: nil, # NB: cancellation_reason must only be specified if status==cancelled
                cancellation_reason_comment: nil,
                move_type: 'court_appearance',
                move_agreed: true,
                move_agreed_by: 'Fred Bloggs',
                date_from: date_from,
                date_to: date_to,
              },
              relationships: { documents: { data: documents } },
            }
          end

          it 'updates the moves documents' do
            expect(move.reload.documents).to match_array(before_documents)
            do_patch
            expect(move.reload.documents).to match_array(after_documents)
          end

          it 'does not affect other relationships' do
            expect { do_patch }.not_to change { move.reload.from_location }
          end

          it 'returns the updated documents in the response body' do
            do_patch

            expect(
              response_json.dig('data', 'relationships', 'documents', 'data').map { |document| document['id'] },
            ).to match_array(after_documents.pluck(:id))
          end

          context 'when there are no attributes in the params' do
            let(:move_params) do
              documents = after_documents.map { |d| { id: d.id, type: 'documents' } }
              {
                type: 'moves',
                relationships: { documents: { data: documents } },
              }
            end

            it 'updates the moves documents' do
              expect(move.reload.documents).to match_array(before_documents)
              do_patch
              expect(move.reload.documents).to match_array(after_documents)
            end

            it 'does not affect other relationships' do
              expect { do_patch }.not_to change { move.reload.from_location }
            end

            it 'returns the updated documents in the response body' do
              do_patch

              expect(
                response_json.dig('data', 'relationships', 'documents', 'data').map { |document| document['id'] },
              ).to match_array(after_documents.pluck(:id))
            end
          end

          context 'when documents is an empty array' do
            let(:move_params) do
              {
                type: 'moves',
                relationships: { documents: { data: [] } },
              }
            end

            it 'removes the documents from the move' do
              expect(move.reload.documents).to match_array(before_documents)
              do_patch
              expect(move.reload.documents).to match_array([])
            end
          end

          context 'when documents is nil' do
            let(:move_params) do
              {
                type: 'moves',
                relationships: { documents: { data: nil } },
              }
            end

            it 'does not remove documents from the move' do
              expect(move.reload.documents).to match_array(before_documents)
              do_patch
              expect(move.reload.documents).to match_array(before_documents)
            end
          end
        end

        context 'when changing a moves person' do
          let(:after_person) { create(:person) }
          let(:move_params) do
            {
              type: 'moves',
              attributes: {
                status: 'requested',
              },
              relationships: { person: { data: { id: after_person.id, type: 'people' } } },
            }
          end

          it 'updates the moves person' do
            expect(move.reload.profile.person).to eq(after_person)
          end

          it 'does not affect other relationships', :skip_before do
            expect { do_patch }.not_to change { move.reload.from_location }
          end

          it 'returns the updated documents in the response body' do
            expect(
              response_json.dig('data', 'relationships', 'person', 'data', 'id'),
            ).to eq(after_person.id)
          end

          context 'when person is nil' do
            let(:move_params) do
              {
                type: 'moves',
                attributes: {
                  status: 'requested',
                },
                relationships: { person: { data: nil } },
              }
            end

            it 'unlinks profile from the move' do
              expect(move.reload.profile).to be_nil
            end
          end

          context 'when there is no relationship defined' do
            let(:before_person) { create(:person) }
            let!(:move) { create :move, :proposed, move_type: 'prison_recall', from_location: from_location, profile: before_person.latest_profile }
            let(:move_params) do
              {
                type: 'moves',
                attributes: {
                  status: 'requested',
                },
              }
            end

            it 'does nothing to person on move' do
              expect(move.reload.profile.person).to eq(before_person)
            end
          end
        end

        context 'when cancelling a move' do
          context 'when the supplier has a webhook subscription', :skip_before do
            let!(:subscription) { create(:subscription, :no_email_address, supplier: supplier) }
            let!(:notification_type_webhook) { create(:notification_type, :webhook) }
            let(:notification) { subscription.notifications.last }
            let(:faraday_client) {
              class_double(Faraday, headers: {}, post:
                  instance_double(Faraday::Response, success?: true, status: 202))
            }

            before do
              allow(Faraday).to receive(:new).and_return(faraday_client)
              perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
                do_patch
              end
            end

            it { expect(notification.delivered_at).not_to be_nil }
            it { expect(notification.topic).to eql(move) }
            it { expect(notification.notification_type).to eql(notification_type_webhook) }
            it { expect(notification.event_type).to eql('update_move_status') }
            it { expect(notification.response_id).to be_nil }
          end

          context 'when the supplier has an email subscription', :skip_before do
            let!(:subscription) { create(:subscription, :no_callback_url, supplier: supplier) }
            let!(:notification_type_email) { create(:notification_type, :email) }
            let(:notification) { subscription.notifications.last }
            let(:notify_response) {
              instance_double(ActionMailer::MessageDelivery, deliver_now!:
                  instance_double(Mail::Message, govuk_notify_response:
                      instance_double(Notifications::Client::ResponseNotification, id: response_id)))
            }
            let(:response_id) { SecureRandom.uuid }

            before do
              allow(MoveMailer).to receive(:notify).and_return(notify_response)
              perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyEmailJob]) do
                do_patch
              end
            end

            it { expect(notification.delivered_at).not_to be_nil }
            it { expect(notification.topic).to eql(move) }
            it { expect(notification.notification_type).to eql(notification_type_email) }
            it { expect(notification.event_type).to eql('update_move_status') }
            it { expect(notification.response_id).to eql(response_id) }
          end
        end

        context 'when updating an existing requested move without a change of move_status' do
          let!(:move) { create :move, :requested, move_type: 'prison_recall', from_location: from_location }

          context 'when the supplier has a webhook subscription', :skip_before do
            # NB: updates to existing moves should trigger a webhook notification
            let!(:subscription) { create(:subscription, :no_email_address, supplier: supplier) }
            let!(:notification_type_webhook) { create(:notification_type, :webhook) }
            let(:notification) { subscription.notifications.last }
            let(:faraday_client) {
              class_double(Faraday, headers: {}, post:
                  instance_double(Faraday::Response, success?: true, status: 202))
            }
            let(:move_params) do
              {
                type: 'moves',
                attributes: {
                  status: move.status,
                },
              }
            end

            before do
              allow(Faraday).to receive(:new).and_return(faraday_client)
              perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
                do_patch
              end
            end

            it { expect(notification.delivered_at).not_to be_nil }
            it { expect(notification.topic).to eql(move) }
            it { expect(notification.notification_type).to eql(notification_type_webhook) }
            it { expect(notification.event_type).to eql('update_move') }
            it { expect(notification.response_id).to be_nil }
          end

          context 'when the supplier has an email subscription', :skip_before do
            # NB: updates to existing moves should trigger an email notification
            let!(:subscription) { create(:subscription, :no_callback_url, supplier: supplier) }
            let!(:notification_type_email) { create(:notification_type, :email) }
            let(:notification) { subscription.notifications.last }
            let(:notify_response) {
              instance_double(ActionMailer::MessageDelivery, deliver_now!:
                  instance_double(Mail::Message, govuk_notify_response:
                      instance_double(Notifications::Client::ResponseNotification, id: response_id)))
            }
            let(:response_id) { SecureRandom.uuid }
            let(:move_params) do
              {
                type: 'moves',
                attributes: {
                  status: move.status,
                },
              }
            end

            before do
              allow(MoveMailer).to receive(:notify).and_return(notify_response)
              perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyEmailJob]) do
                do_patch
              end
            end

            it 'creates an email notification' do
              expect(subscription.notifications.count).to be 1
            end
          end
        end
      end

      context 'with a read-only attribute' do
        let!(:move) { create :move }

        let(:move_params) do
          {
            type: 'moves',
            attributes: {
              status: 'cancelled',
              cancellation_reason: 'supplier_declined_to_move',
              reference: 'new reference',
            },
          }
        end

        it_behaves_like 'an endpoint that responds with success 200'

        it 'updates the status of a move', skip_before: true do
          do_patch
          expect(move.reload.status).to eq 'cancelled'
        end

        it 'does NOT update the reference of a move', skip_before: true do
          expect { do_patch }.not_to(
            change { move.reload.reference },
            )
        end
      end

      context 'with a bad request' do
        let(:move_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'when from nomis' do
        let(:nomis_event_id) { 12_345_678 }
        let!(:move) { create :move, nomis_event_ids: [nomis_event_id] }
        let(:detail_403) { 'Can\'t change moves coming from Nomis' }

        let(:move_params) do
          {
            type: 'moves',
            attributes: {
              status: 'cancelled',
              cancellation_reason: 'supplier_declined_to_move',
              reference: 'new reference',
            },
          }
        end

        it_behaves_like 'an endpoint that responds with error 403'
      end

      context 'with a missing move' do
        let(:move_id) { 'null' }
        let(:detail_404) { "Couldn't find Move with 'id'=null" }

        it_behaves_like 'an endpoint that responds with error 404'
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:content_type) { 'application/xml' }

        it_behaves_like 'an endpoint that responds with error 415'
      end

      context 'with validation errors' do
        let(:move_params) do
          {
            type: 'moves',
            attributes: {
              status: 'invalid',
            },
          }
        end

        let(:errors_422) do
          [
            {
              'title' => 'Unprocessable entity',
              'detail' => 'Status is not included in the list',
              'source' => { 'pointer' => '/data/attributes/status' },
              'code' => 'inclusion',
            },
          ]
        end

        it_behaves_like 'an endpoint that responds with error 422'
      end
    end
  end

  def do_patch
    patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers: headers, as: :json
  end
end
