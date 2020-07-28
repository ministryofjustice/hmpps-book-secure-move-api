# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Alerts::Importer do
  subject(:importer) do
    described_class.new(
      profile: profile,
      alerts: alerts,
    )
  end

  let(:person) { create :person, :nomis_synced }
  let(:profile) { person.latest_profile }
  let(:alerts) do
    [
      {
        offender_no: person.nomis_prison_number,
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
        rnum: 1,
      },
      {
        offender_no: person.nomis_prison_number,
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
        rnum: 2,
      },
    ]
  end
  let!(:fallback_assessment_question) { create :assessment_question, :alerts_fallback }
  let(:prison_numbers_response) { [{ prison_number: person.nomis_prison_number, first_name: 'Bob' }] }
  let(:moves) do
    [{
      person_nomis_prison_number: person.nomis_prison_number,
      from_location_nomis_agency_id: 'BXI',
      to_location_nomis_agency_id: 'WDGRCC',
      date: '2019-08-19',
      time_due: '2019-08-19T17:00:00',
      status: 'requested',
    }]
  end

  before do
    allow(NomisClient::People).to receive(:get).and_return(prison_numbers_response)
    allow(NomisClient::Alerts).to receive(:get).and_return(alerts)
    allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return([])

    create(:location, nomis_agency_id: 'BXI')
  end

  context 'with no relevant nomis alert mappings' do
    let(:answers) do
      importer.call
      profile.assessment_answers
    end

    it 'creates new assessment answers' do
      expect { importer.call }.to change { profile.assessment_answers.count }.by(2)
    end

    it 'sets the nomis alert code' do
      expect(answers.map(&:nomis_alert_code)).to eq %w[XVL XEL]
    end

    it 'sets the nomis alert type' do
      expect(answers.map(&:nomis_alert_type)).to eq %w[X X]
    end

    it 'sets the fallback assessment question id' do
      expect(answers.first&.assessment_question_id).to eq fallback_assessment_question.id
    end

    it 'sets imported_from_nomis' do
      expect(answers.map(&:imported_from_nomis)).to eq [true, true]
    end

    it 'sets the title to the value of the question title' do
      expect(answers.map(&:title)).to eq ['Other Risks', 'Other Risks']
    end

    it 'sets the nomis_alert_type_description' do
      expect(answers.map(&:nomis_alert_type_description)).to eq %w[Security Security]
    end

    it 'sets the nomis_alert_description' do
      expect(answers.map(&:nomis_alert_description)).to eq ['Violent', 'Escape List']
    end

    it 'sets the comments' do
      expect(answers.map(&:comments)).to eq ['Threatening to take staff hostage',
                                             'Caught in possession of a rock hammer']
    end
  end

  context 'with a relevant nomis alert mapping' do
    let(:assessment_question) { create :assessment_question, :risk }
    let!(:nomis_alert) do
      create(
        :nomis_alert,
        type_code: 'X',
        code: 'XVL',
        assessment_question_id: assessment_question.id,
      )
    end

    it 'creates new assessment answers' do
      expect { importer.call }.to change { profile.assessment_answers.count }.by(2)
    end

    it 'sets the assessment question id' do
      importer.call
      expect(profile.assessment_answers&.first&.assessment_question_id).to eq assessment_question.id
    end
  end
end
