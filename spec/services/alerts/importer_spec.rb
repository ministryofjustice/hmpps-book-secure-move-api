# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Alerts::Importer do
  subject(:importer) do
    described_class.new(
      profile: profile,
      alerts: alerts
    )
  end

  let(:person) { create :person }
  let(:profile) { person.latest_profile }
  let(:alerts) do
    [
      {
        alert_id: 1,
        alert_type: 'X',
        alert_type_description: 'Security',
        alert_code: 'XVL',
        alert_code_description: 'Violent',
        comment: 'Threatening to take staff hostage',
        created_at: '2018-07-29',
        expires_at: nil,
        expired: false,
        active: true,
        rnum: 1
      },
      {
        alert_id: 2,
        alert_type: 'X',
        alert_type_description: 'Security',
        alert_code: 'XEL',
        alert_code_description: 'Escape List',
        comment: 'Caught in possession of a rock hammer',
        created_at: '2017-06-15',
        expires_at: nil,
        expired: false,
        active: true,
        rnum: 2
      }
    ]
  end

  context 'with no relevant nomis alert mappings' do
    it 'creates new assessment answers' do
      expect { importer.call }.to change { profile.reload.assessment_answers.count }.by(2)
    end

    it 'sets the nomis alert code' do
      importer.call
      expect(profile.reload.assessment_answers&.first&.nomis_alert_code).to eq 'XVL'
    end

    it 'sets the nomis alert type' do
      importer.call
      expect(profile.reload.assessment_answers&.first&.nomis_alert_type).to eq 'X'
    end

    it 'leaves the assessment question id blank' do
      importer.call
      expect(profile.reload.assessment_answers&.first&.assessment_question_id).to be_nil
    end

    it 'sets imported_from_nomis' do
      importer.call
      expect(profile.reload.assessment_answers&.first&.imported_from_nomis).to be true
    end
  end

  context 'with a relevant nomis alert mapping' do
    let(:assessment_question) { create :assessment_question }
    let!(:nomis_alert) do
      create(
        :nomis_alert,
        type_code: 'X',
        code: 'XVL',
        assessment_question_id: assessment_question.id
      )
    end

    it 'creates new assessment answers' do
      expect { importer.call }.to change { profile.reload.assessment_answers.count }.by(2)
    end

    it 'sets the assessment question id' do
      importer.call
      expect(profile.reload.assessment_answers&.first&.assessment_question_id).to eq assessment_question.id
    end
  end
end
