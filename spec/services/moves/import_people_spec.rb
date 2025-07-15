# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::ImportPeople do
  subject(:importer) { described_class.new(input_data) }

  let(:input_data) { [nomis_prison_number] }
  let(:nomis_prison_number) { 'G3239GV' }

  let(:alerts_response) do
    [
      {
        offender_no: nomis_prison_number,
        alert_code: 'ACCU9',
        alert_type: 'MATSTAT',
      },
    ]
  end
  let(:prison_numbers_response) do
    [
      {
        prison_number: nomis_prison_number,
        first_name: 'Bob',
        last_name: 'Beep',
      },
    ]
  end
  let(:personal_care_needs_response) do
    [
      {
        offender_no: nomis_prison_number,
        problem_type: 'FOO',
        problem_code: 'AA',
      },
    ]
  end

  before do
    allow(NomisClient::People).to receive(:get).and_return(prison_numbers_response)
    # Mock individual calls (new behavior) but not batch calls (old behavior)
    allow(AlertsApiClient::Alerts).to receive(:get).with(nomis_prison_number).and_return(alerts_response)
    allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return(personal_care_needs_response)
    create(:assessment_question, :care_needs_fallback)
    create(:assessment_question, :alerts_fallback)
  end

  context 'with an existing record' do
    before do
      create(:person, nomis_prison_number:, prison_number: nomis_prison_number)
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

      before do
        # Override the mock for empty alerts case
        allow(AlertsApiClient::Alerts).to receive(:get).with(nomis_prison_number).and_return([])
      end

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
end
