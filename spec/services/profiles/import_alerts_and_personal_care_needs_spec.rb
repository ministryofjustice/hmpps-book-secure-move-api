# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::ImportAlertsAndPersonalCareNeeds, :with_hmpps_authentication do
  let(:person) { create :person, :nomis_synced }
  let(:prison_number) { person.prison_number }
  let(:profile) { create(:profile, person:) }

  before do
    create :assessment_question, :care_needs_fallback
    create :assessment_question, :alerts_fallback
  end

  context 'when alert is present' do
    before do
      allow(token).to receive(:get) do |url|
        if url.include?('alerts')
          instance_double(OAuth2::Response, body: alerts_body, parsed: JSON.parse(alerts_body), status: 200)
        else
          instance_double(OAuth2::Response, body: personal_care_needs_body, parsed: JSON.parse(personal_care_needs_body), status: 200)
        end
      end
    end

    let(:alerts_body) do
      {
        'content' => [
          {
            'prisonNumber' => person.prison_number,
            'alertCode' => { 'code' => 'ACCU9', 'alertTypeCode' => 'MATSTAT' },
          },
        ],
      }.to_json
    end

    let(:personal_care_needs_body) { { 'personalCareNeeds' => [] }.to_json }

    it 'updates the profile' do
      described_class.new(profile, prison_number).call
      expect(profile.assessment_answers[0]).to have_attributes({ 'nomis_alert_code' => 'ACCU9', 'nomis_alert_type' => 'MATSTAT' })
    end
  end

  context 'when personal_care_needs is present' do
    before do
      allow(token).to receive(:get) do |url|
        if url.include?('alerts')
          instance_double(OAuth2::Response, body: alerts_body, parsed: JSON.parse(alerts_body), status: 200)
        else
          instance_double(OAuth2::Response, body: personal_care_needs_body, parsed: JSON.parse(personal_care_needs_body), status: 200)
        end
      end
    end

    let(:alerts_body) { { 'content' => [] }.to_json }

    let(:personal_care_needs_body) do
      {
        'personalCareNeeds' => [
          { 'problemType' => 'FOO', 'problemCode' => 'AA' },
        ],
      }.to_json
    end

    it 'updates the profile' do
      described_class.new(profile, prison_number).call
      expect(profile.assessment_answers[0]).to have_attributes({ 'nomis_alert_type' => 'FOO', 'nomis_alert_code' => 'AA' })
    end
  end
end
