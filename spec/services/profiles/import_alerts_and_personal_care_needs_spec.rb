# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::ImportAlertsAndPersonalCareNeeds, :with_nomis_client_authentication do
  let(:person) { create :person, :nomis_synced }
  let(:prison_number) { person.prison_number }
  let(:profile) { create(:profile, person:) }
  let(:alerts_response_body) { [] }
  let(:personal_care_needs_response_body) { [{ 'offenderNo' => prison_number, 'personalCareNeeds' => [] }] }

  let(:alerts_response) do
    instance_double(
      OAuth2::Response,
      body: alerts_response_body.to_json,
      parsed: alerts_response_body,
      status: 200,
    )
  end
  let(:personal_care_needs_response) do
    instance_double(
      OAuth2::Response,
      body: personal_care_needs_response_body.to_json,
      parsed: personal_care_needs_response_body,
      status: 200,
    )
  end

  before do
    create :assessment_question, :care_needs_fallback
    create :assessment_question, :alerts_fallback

    allow(token).to receive(:post).and_return(alerts_response, personal_care_needs_response)
  end

  context 'when alert is present' do
    let(:alerts_response_body) { [{ 'offenderNo' => person.prison_number, 'alertCode' => 'ACCU9', 'alertType' => 'MATSTAT' }] }

    it 'updates the profile' do
      described_class.new(profile, prison_number).call

      expect(profile.assessment_answers[0]).to have_attributes({ 'nomis_alert_code' => 'ACCU9', 'nomis_alert_type' => 'MATSTAT' })
    end
  end

  context 'when personal_care_needs is present' do
    let(:personal_care_needs_response_body) do
      [
        {
          'offenderNo' => prison_number,
          'personalCareNeeds' => [
            { 'problemType' => 'FOO', 'problemCode' => 'AA' },
          ],
        },
      ]
    end

    it 'updates the profile' do
      described_class.new(profile, prison_number).call

      expect(profile.assessment_answers[0]).to have_attributes({ 'nomis_alert_type': 'FOO', 'nomis_alert_code': 'AA' })
    end
  end
end
