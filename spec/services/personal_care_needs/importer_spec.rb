# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonalCareNeeds::Importer do
  subject(:importer) do
    described_class.new(
      profile: profile,
      personal_care_needs: personal_care_needs,
    )
  end

  let(:person) { create :person, :nomis_synced }
  let(:profile) { person.latest_profile }
  let(:personal_care_needs) do
    [
      {
        offender_no: person.nomis_prison_number,
        problem_type: 'MATSTAT',
        problem_code: 'ACCU9',
        problem_status: 'ON',
        problem_description: 'Preg, acc under 9mths',
        start_date: '2010-06-21',
        end_date: '2010-06-21',
      },
    ]
  end
  let(:moves) do
    [{
      person_nomis_prison_number: person.nomis_prison_number,
      from_location_nomis_agency_id: 'BXI',
      to_location_nomis_agency_id: 'WDGRCC',
      date: '2019-08-19',
      time_due: '2019-08-19T17:00:00',
      status: 'requested',
      nomis_event_id: 123_456,
    }]
  end
  let(:prison_numbers_response) { [{ prison_number: person.nomis_prison_number, first_name: 'Bob' }] }

  let!(:pregnant_question) { create :assessment_question, key: :pregnant, title: 'Pregnant' }

  before do
    allow(NomisClient::People).to receive(:get).and_return(prison_numbers_response)
    allow(NomisClient::Alerts).to receive(:get).and_return([])
    allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return(personal_care_needs)

    create(:location, nomis_agency_id: 'BXI')
  end

  context 'with no relevant nomis alert mappings' do
    it 'creates a new assessment answer' do
      expect { importer.call }.to change { profile.assessment_answers.count }.by(1)
    end

    it 'sets the nomis alert code' do
      importer.call
      expect(profile.assessment_answers.map(&:nomis_alert_code)).to eq %w[ACCU9]
    end
  end
end
