# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MovesController do
  include ActiveJob::TestHelper

  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }
  let(:resource_to_json) do
    ActiveStorage::Current.url_options = { protocol: 'http', host: 'www.example.com', port: 80 } # This is used in the serializer
    JSON.parse(MoveSerializer.new(move.reload, include: MoveSerializer::SUPPORTED_RELATIONSHIPS).serializable_hash.to_json)
  end

  let(:detail_404) { "Couldn't find Move with 'id'=UUID-not-found" }

  describe 'PATCH /moves' do
    let(:schema) { load_yaml_schema('patch_move_responses.yaml') }
    let(:supplier) { create(:supplier) }
    let!(:from_location) { create :location, :police, suppliers: [supplier] }
    let(:profile) { create(:profile, documents: before_documents) }
    let!(:move) { create :move, :proposed, :prison_recall, from_location:, profile:, supplier: }
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
          date_from:,
          date_to:,
        },
      }
    end

    before do
      next if RSpec.current_example.metadata[:skip_before]

      do_patch
    end

    context 'when authorized' do
      let(:headers) do
        {
          'Content-Type': content_type,
          'Authorization' => "Bearer #{access_token}",
          'Idempotency-Key' => SecureRandom.uuid,
        }
      end

      let(:access_token) { 'spoofed-token' }

      context 'with an existing requested move', :skip_before do
        before do
          create(
            :move,
            :requested,
            profile:,
            from_location: move.from_location,
            to_location: move.to_location,
            date: move.date,
            supplier:,
          )
          do_patch
        end

        let(:errors_422) do
          [
            {
              'title' => 'Unprocessable content',
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
          expect(result.cancellation_reason).to be_nil
        end

        it 'does not update the cancellation_reason_comment of a move' do
          expect(result.cancellation_reason_comment).to be_nil
        end

        it 'returns the correct data' do
          # NB this test was a bit flaky on CircleCI due to the way active storage URLs are generated and cached - the
          # fix here strips out the inner path from the url
          expect(clean_active_storage_urls(response_json.to_json)).to eq clean_active_storage_urls(resource_to_json.to_json)
        end

        context 'when changing a moves profile documents', :skip_before do
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
                date_from:,
                date_to:,
              },
              relationships: { documents: { data: documents } },
            }
          end

          it 'updates the moves profile documents' do
            expect(move.profile.documents).to match_array(before_documents)
            do_patch
            expect(move.reload.profile.documents).to match_array(after_documents)
          end

          it 'does not affect other relationships' do
            expect { do_patch }.not_to(change { move.reload.from_location })
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

            it 'updates the moves profile documents' do
              expect(move.profile.documents).to match_array(before_documents)
              do_patch
              expect(move.reload.profile.documents).to match_array(after_documents)
            end

            it 'does not affect other relationships' do
              expect { do_patch }.not_to(change { move.reload.from_location })
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
              expect(move.profile.documents).to match_array(before_documents)
              do_patch
              expect(move.reload.profile.documents).to be_empty
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
              expect(move.profile.documents).to match_array(before_documents)
              do_patch
              expect(move.reload.profile.documents).to match_array(before_documents)
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
            expect { do_patch }.not_to(change { move.reload.from_location })
          end

          it 'returns the updated person in the response body' do
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
            let!(:move) { create :move, :proposed, move_type: 'prison_recall', from_location:, profile: before_person.latest_profile }
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

        context 'when changing a moves profile' do
          let(:after_profile) { create(:profile) }
          let(:move_params) do
            {
              type: 'moves',
              attributes: {
                status: 'requested',
              },
              relationships: { profile: { data: { id: after_profile.id, type: 'profiles' } } },
            }
          end

          it 'updates the moves profile' do
            expect(move.reload.profile).to eq(after_profile)
          end

          it 'does not affect other relationships', :skip_before do
            expect { do_patch }.not_to(change { move.reload.from_location })
          end

          it 'returns the updated profile in the response body' do
            expect(
              response_json.dig('data', 'relationships', 'profile', 'data', 'id'),
            ).to eq(after_profile.id)
          end

          context 'when profile is nil' do
            let(:move_params) do
              {
                type: 'moves',
                attributes: {
                  status: 'requested',
                },
                relationships: { profile: { data: nil } },
              }
            end

            it 'unlinks profile from the move' do
              expect(move.reload.profile).to be_nil
            end
          end

          context 'when there is no relationship defined' do
            let(:before_profile) { create(:profile) }
            let!(:move) { create :move, :proposed, move_type: 'prison_recall', from_location:, profile: before_profile }
            let(:move_params) do
              {
                type: 'moves',
                attributes: {
                  status: 'requested',
                },
              }
            end

            it 'does nothing to profile on move' do
              expect(move.reload.profile).to eq(before_profile)
            end
          end
        end

        # TODO: Remove when people/profiles migration is completed
        context 'when changing a moves profile and person' do
          let(:person) { create(:person) }
          let(:profile) { create(:profile) }

          let(:move_params) do
            {
              type: 'moves',
              attributes: {
                status: 'requested',
              },
              relationships: {
                profile: { data: { id: profile.id, type: 'profiles' } },
                person: { data: { id: person.id, type: 'people' } },
              },
            }
          end

          it 'updates the moves profile as the default' do
            expect(move.reload.profile).to eq(profile)
          end

          it 'returns the profile person in the response' do
            expected_response = { 'type' => 'people', 'id' => profile.person.id }

            expect(response_json.dig('data', 'relationships', 'person', 'data')).to eq(expected_response)
          end
        end

        context 'when cancelling a move' do
          let(:move_params) do
            {
              type: 'moves',
              attributes: {
                status: 'cancelled',
                cancellation_reason: 'other',
              },
            }
          end

          context 'with an associated allocation' do
            let!(:allocation) { create :allocation, moves_count: 1 }
            let!(:move) { create :move, :requested, from_location:, allocation: }

            it 'updates the allocation moves_count' do
              expect(allocation.reload.moves_count).to eq(0)
            end

            it 'updates the allocation status to unfilled' do
              expect(move.reload.allocation).to be_unfilled
            end
          end

          context 'when the supplier has a webhook subscription', :skip_before do
            let!(:subscription) { create(:subscription, :no_email_address, supplier:) }
            let!(:notification_type_webhook) { create(:notification_type, :webhook) }
            let(:notification) { subscription.notifications.order(:created_at).last }
            let(:faraday_client) do
              class_double(
                Faraday,
                headers: {},
                post: instance_double(Faraday::Response, success?: true, status: 202),
              )
            end

            before do
              allow(Faraday).to receive(:new).and_return(faraday_client)
              perform_enqueued_jobs(only: [PrepareMoveNotificationsJob, NotifyWebhookJob]) do
                do_patch
              end
            end

            it 'has correct attributes' do
              expect(notification).to have_attributes(
                delivered_at: a_value,
                topic: move,
                notification_type: notification_type_webhook,
                event_type: 'update_move_status',
                response_id: nil,
              )
            end
          end

          context 'when the supplier has an email subscription', :skip_before do
            let!(:subscription) { create(:subscription, :no_callback_url, supplier:) }
            let!(:notification_type_email) { create(:notification_type, :email) }
            let(:notification) { subscription.notifications.order(:created_at).last }
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
                do_patch
              end
            end

            it 'has correct attributes' do
              expect(notification).to have_attributes(
                delivered_at: a_value,
                topic: move,
                notification_type: notification_type_email,
                event_type: 'update_move_status',
                response_id:,
              )
            end
          end
        end

        context 'when updating an existing requested move without a change of move_status' do
          let!(:move) { create :move, :requested, move_type: 'prison_recall', from_location:, supplier: }

          context 'when the supplier has a webhook subscription', :skip_before do
            # NB: updates to existing moves should trigger a webhook notification
            let!(:subscription) { create(:subscription, :no_email_address, supplier:) }
            let!(:notification_type_webhook) { create(:notification_type, :webhook) }
            let(:notification) { subscription.notifications.order(:created_at).last }
            let(:faraday_client) do
              class_double(
                Faraday,
                headers: {},
                post: instance_double(Faraday::Response, success?: true, status: 202),
              )
            end
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

            it 'has correct attributes' do
              expect(notification).to have_attributes(
                delivered_at: a_value,
                topic: move,
                notification_type: notification_type_webhook,
                event_type: 'update_move',
                response_id: nil,
              )
            end
          end

          context 'when the supplier has an email subscription', :skip_before do
            # NB: updates to existing moves should trigger an email notification
            let!(:subscription) { create(:subscription, :no_callback_url, supplier:) }
            let(:notification) { subscription.notifications.order(:created_at).last }
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
            let(:move_params) do
              {
                type: 'moves',
                attributes: {
                  status: move.status,
                },
              }
            end

            before do
              create(:notification_type, :email)

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

        context 'when move is associated to an allocation' do
          let!(:move) { create :move, :with_allocation, profile:, supplier: }
          let(:move_params) do
            {
              type: 'moves',
              attributes: {
                status: 'cancelled',
                cancellation_reason: 'other',
              },
            }
          end

          it 'updates the allocation status to unfilled' do
            expect(move.reload.allocation).to be_unfilled
          end

          context 'when linking a person' do
            let!(:move) { create :move, :with_allocation, profile: nil }
            let(:move_params) do
              {
                type: 'moves',
                attributes: {
                  status: 'requested',
                },
                relationships: { person: { data: { id: profile.person.id, type: 'people' } } },
              }
            end

            it 'updates the allocation status to filled' do
              expect(move.reload.allocation).to be_filled
            end
          end

          context 'when unlinking a person' do
            let!(:move) { create :move, :with_allocation, profile: }
            let(:move_params) do
              {
                type: 'moves',
                attributes: {
                  status: 'requested',
                },
                relationships: { person: { data: nil } },
              }
            end

            it 'updates the allocation status to unfilled' do
              expect(move.reload.allocation).to be_unfilled
            end
          end

          context 'when linking a profile' do
            let!(:move) { create :move, :with_allocation, profile: nil }
            let(:profile) { create(:profile) }
            let(:move_params) do
              {
                type: 'moves',
                attributes: {
                  status: 'requested',
                },
                relationships: { profile: { data: { id: profile.id, type: 'profiles' } } },
              }
            end

            it 'updates the allocation status to filled' do
              expect(move.reload.allocation).to be_filled
            end
          end

          context 'when unlinking a profile' do
            let(:profile) { create(:profile) }
            let!(:move) { create :move, :with_allocation, profile: }
            let(:move_params) do
              {
                type: 'moves',
                attributes: {
                  status: 'requested',
                },
                relationships: { profile: { data: nil } },
              }
            end

            it 'updates the allocation status to unfilled' do
              expect(move.reload.allocation).to be_unfilled
            end
          end
        end

        context 'when updating the date' do
          let(:move_params) do
            {
              type: 'moves',
              attributes: {
                date: '2019-08-23',
                date_changed_reason: 'operational_issues',
              },
            }
          end

          let(:move_date_changed_event) { move.generic_events.where(type: 'GenericEvent::MoveDateChanged').first }

          it 'changes the move date' do
            do_patch
            expect(move.reload.date).to eql Date.parse('2019-08-23')
          end

          it 'saves the move date_changed_reason' do
            do_patch
            expect(move.reload.date_changed_reason).to eql 'operational_issues'
          end

          it 'creates a GenericEvent::MoveDateChanged event' do
            do_patch
            expect(move_date_changed_event).to be_present
            expect(move_date_changed_event.date).to eql '2019-08-23'
            expect(move_date_changed_event.date_changed_reason).to eql 'operational_issues'
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

        it 'updates the status of a move', :skip_before do
          do_patch
          expect(move.reload.status).to eq 'cancelled'
        end

        it 'does NOT update the reference of a move', :skip_before do
          expect { do_patch }.not_to(
            change { move.reload.reference },
          )
        end
      end

      context 'with a bad request' do
        let(:move_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'with a missing move' do
        let(:move_id) { 'null' }
        let(:detail_404) { "Couldn't find Move with 'id'=null" }

        it_behaves_like 'an endpoint that responds with error 404'
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
              'title' => 'Invalid status',
              'detail' => /Status is not included in the list/,
            },
          ]
        end

        it_behaves_like 'an endpoint that responds with error 422'
      end
    end
  end

  def do_patch
    patch "/api/v1/moves/#{move_id}", params: { data: move_params }, headers:, as: :json
  end

  def clean_active_storage_urls(text)
    # this strips the path from test active storage urls, in order to prevent a flaky test in CircleCI
    # e.g. "http://www.example.com/rails/active_storage/disk/XXX/YYY/ZZZ/file-sample_100kB.doc?content_type=AAA&disposition=BBB"
    # ---> "http://www.example.com/file-sample_100kB.doc?content_type=AAA&disposition=BBB"
    text.gsub(/("https?:\/\/www\.example\.com\/)([^"]+)\/([^"]+")/, '\1\3')
  end
end
