# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::ImportAlertsAndPersonalCareNeeds do
  # let(:person) { create :person, :nomis_synced }
  # let(:prison_number) { person.prison_number }
  # let(:profile) { create(:profile, person: person) }
  # let(:alerts_response) { [] }
  # let(:personal_care_needs_response) { [] }
  #
  # before do
  #   create :assessment_question, :care_needs_fallback
  #   create :assessment_question, :alerts_fallback
  #
  #   allow(NomisClient::Alerts).to receive(:get).and_return(alerts_response)
  #   allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return(personal_care_needs_response)
  # end
  #
  # context 'when alert is present' do
  #   let(:alerts_response) { [{ offender_no: person.prison_number, alert_code: 'ACCU9', alert_type: 'MATSTAT' }] }
  #
  #   it 'updates the profile' do
  #     described_class.call(profile, prison_number)
  #
  #     expect(profile.assessment_answers[0].attributes).to include({ 'nomis_alert_code' => 'ACCU9', 'nomis_alert_type' => 'MATSTAT' })
  #   end
  # end
  #
  # context 'when personal_care_needs is present' do
  #   let(:personal_care_needs_response) { [{ offender_no: person.prison_number, problem_type: 'FOO', problem_code: 'AA' }] }
  #
  #   it 'updates the profile' do
  #     described_class.call(profile, prison_number)
  #
  #     expect(profile.assessment_answers[0].attributes).to include({ 'nomis_alert_type': 'FOO', 'nomis_alert_code': 'AA' })
  #   end
  # end
end
