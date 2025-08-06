# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::ImportPeople, :with_hmpps_authentication, :with_prisoner_search_api do
  subject(:importer) { described_class.new(input_data) }

  let(:input_data) { [prison_number] }
  let(:response_body) { file_fixture('prisoner_search_api/get_prisoner_200.json').read }
  let(:response_status) { 200 }
  let(:prison_number) { JSON.parse(response_body)['prisonerNumber'] } # A1234AA

  let(:alerts_response) do
    [
      {
        prison_number: prison_number,
        alert_code: 'ACCU9',
        alert_type: 'MATSTAT',
      },
    ]
  end

  let(:personal_care_needs_response) do
    [
      {
        offender_no: prison_number,
        problem_type: 'FOO',
        problem_code: 'AA',
      },
    ]
  end

  before do
    allow(AlertsApiClient::Alerts).to receive(:get).and_return(alerts_response)
    allow(PrisonerSearchApiClient::PersonalCareNeeds).to receive(:get).and_return(personal_care_needs_response)

    create(:assessment_question, :care_needs_fallback)
    create(:assessment_question, :alerts_fallback)
  end

  context 'with an existing record' do
    before do
      create(:person, nomis_prison_number: prison_number, prison_number: prison_number)
    end

    it 'keeps people the same' do
      expect { importer.call }.not_to change(Person, :count)
    end

    it 'keeps profiles the same' do
      expect { importer.call }.not_to change(Profile, :count)
    end
  end

  context 'with no existing records' do
    it 'creates new `Person` records' do
      expect { importer.call }.to change(Person, :count).by(1)
    end

    it 'creates new `Profile` records' do
      expect { importer.call }.to change(Profile, :count).by(1)
    end

    it 'populates assessment answers' do
      importer.call
      assessment_answers = Person.last.profiles.first.assessment_answers
      expect(assessment_answers).to be_present
    end

    context 'with no alerts or personal care needs' do
      let(:alerts_response) { [] }
      let(:personal_care_needs_response) { [] }

      it 'creates new `Person` records' do
        expect { importer.call }.to change(Person, :count).by(1)
      end

      it 'creates new `Profile` records' do
        expect { importer.call }.to change(Profile, :count).by(1)
      end

      it 'does not populate assessment answers' do
        importer.call
        assessment_answers = Person.last.profiles.first.assessment_answers
        expect(assessment_answers).to be_empty
      end
    end
  end

  context 'with single prison number string (not array)' do
    let(:input_data) { prison_number } # String instead of array

    it 'handles single string input correctly' do
      expect { importer.call }.to change(Person, :count).by(1)
    end
  end

  context 'when prisoner search API fails' do
    before do
      allow(PrisonerSearchApiClient::Prisoner).to receive(:get).with(prison_number).and_return(nil)
    end

    it 'does not create any records' do
      expect { importer.call }.not_to change(Person, :count)
      expect { importer.call }.not_to change(Profile, :count)
    end
  end

  context 'when alerts API fails' do
    before do
      allow(AlertsApiClient::Alerts).to receive(:get).with(prison_number).and_raise(StandardError, 'API Error')
    end

    it 'raises an error and does not create any records' do
      expect { importer.call }.to raise_error(StandardError, 'API Error')
      expect(Person.count).to eq(0)
      expect(Profile.count).to eq(0)
    end
  end
end
