# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::YouthRiskAssessmentsController do
  describe 'PATCH /youth_risk_assessments/:youth_risk_assessment_id' do
    include_context 'with supplier with spoofed access token'

    subject(:patch_youth_risk_assessment) do
      patch "/api/youth_risk_assessments/#{youth_risk_assessment_id}", params: youth_risk_assessment_params, headers: headers, as: :json

      youth_risk_assessment.reload
    end

    let(:schema) { load_yaml_schema('patch_youth_risk_assessment_responses.yaml') }
    let(:response_json) { JSON.parse(response.body) }
    let(:youth_risk_assessment) { create(:youth_risk_assessment, :with_responses, :completed) }
    let(:youth_risk_assessment_id) { youth_risk_assessment.id }
    let(:status) { 'confirmed' }
    let(:youth_risk_assessment_params) do
      {
        data: {
          "type": 'youth_risk_assessments',
          "attributes": {
            "status": status,
          },
        },
      }
    end

    context 'when successful' do
      before { patch_youth_risk_assessment }

      context 'when status is confirmed' do
        it_behaves_like 'an endpoint that responds with success 200'

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": youth_risk_assessment_id,
            "type": 'youth_risk_assessments',
            "attributes": {
              "status": 'confirmed',
              "version": youth_risk_assessment.framework.version,
              "confirmed_at": youth_risk_assessment.confirmed_at.iso8601,
            },
          })
        end
      end
    end

    context 'when unsuccessful' do
      before { patch_youth_risk_assessment }

      context 'with a bad request' do
        let(:youth_risk_assessment_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'with an invalid status' do
        let(:status) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{ 'title' => 'Invalid status',
               'detail' => 'Validation failed: Status is not included in the list' }]
          end
        end
      end

      context 'when youth_risk_assessment is wrong starting status' do
        let(:youth_risk_assessment) { create(:youth_risk_assessment, :with_responses, :in_progress) }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{ 'title' => 'Invalid status',
               'detail' => "Validation failed: Status can't update to 'confirmed' from 'in_progress'" }]
          end
        end
      end

      context 'when the youth_risk_assessment_id is not found' do
        let(:youth_risk_assessment_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find YouthRiskAssessment with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end

    context 'with subscriptions' do
      let!(:subscription) { create(:subscription, supplier: supplier) }
      let!(:notification_type_email) { create(:notification_type, :email) }
      let!(:notification_type_webhook) { create(:notification_type, :webhook) }
      let(:from_location) { create(:location, :stc, suppliers: [supplier]) }
      let(:move) { create(:move, from_location: from_location, supplier: supplier) }
      let(:youth_risk_assessment) { create(:youth_risk_assessment, :with_responses, :completed, move: move) }

      let(:faraday_client) do
        class_double(
          Faraday,
          headers: {},
          post: instance_double(Faraday::Response, success?: true, status: 202),
        )
      end
      let(:notify_response) do
        instance_double(
          ActionMailer::MessageDelivery,
          deliver_now!:
          instance_double(
            Mail::Message,
            govuk_notify_response:
            instance_double(Notifications::Client::ResponseNotification, id: SecureRandom.uuid),
          ),
        )
      end

      before do
        allow(Faraday).to receive(:new).and_return(faraday_client)
        allow(MoveMailer).to receive(:notify).and_return(notify_response)
        perform_enqueued_jobs(only: [PrepareAssessmentNotificationsJob, NotifyWebhookJob, NotifyEmailJob]) do
          patch_youth_risk_assessment
        end
      end

      it 'creates a webhook notification' do
        notification = subscription.notifications.find_by(notification_type: notification_type_webhook)

        expect(notification).to have_attributes(
          topic: youth_risk_assessment.move,
          notification_type: notification_type_webhook,
          event_type: 'confirm_youth_risk_assessment',
        )
      end

      it 'creates an email notification' do
        notification = subscription.notifications.find_by(notification_type: notification_type_email)

        expect(notification).to have_attributes(
          topic: youth_risk_assessment.move,
          notification_type: notification_type_email,
          event_type: 'confirm_youth_risk_assessment',
        )
      end

      context 'when request is unsuccessful' do
        let(:status) { 'foo-bar' }

        it 'does not create notifications' do
          expect(subscription.notifications).to be_empty
        end
      end
    end
  end
end
