# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::ImportPeople do
  subject(:importer) { described_class.new(input_data) }

  let(:input_data) do
    [nomis_prison_number_one]
  end

  let(:nomis_prison_number_one) { 'G3239GV' }
  let(:nomis_prison_number_two) { 'G7157AB' }

  let(:alerts_response) do
    [{ offender_no: nomis_prison_number_one, alert_code: 'ACCU9', alert_type: 'MATSTAT' },
     { offender_no: nomis_prison_number_two, alert_code: 'ACCU9', alert_type: 'MATSTAT' },
     { offender_no: nomis_prison_number_two, alert_code: 'ACCU4', alert_type: 'MATSTAT' }]
  end
  let(:prison_numbers_response) do
    [{ prison_number: nomis_prison_number_one, first_name: 'Bob', last_name: 'Beep' },
     { prison_number: nomis_prison_number_two, first_name: 'Bob', last_name: 'Boop' }]
  end
  let(:personal_care_needs_response) do
    [{ offender_no: nomis_prison_number_one, problem_type: 'FOO', problem_code: 'AA' },
     { offender_no: nomis_prison_number_two, problem_type: 'FOO', problem_code: 'BAC' },
     { offender_no: nomis_prison_number_two, problem_type: 'FOO', problem_code: 'TTG' }]
  end

  before do
    allow(NomisClient::People).to receive(:get).and_return(prison_numbers_response)
    allow(NomisClient::Alerts).to receive(:get).and_return(alerts_response)
    allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return(personal_care_needs_response)

    create(:assessment_question, :care_needs_fallback)
    create(:assessment_question, :alerts_fallback)
  end

  context 'with one existing record' do
    let!(:prisoner_one) { create(:person, nomis_prison_number: nomis_prison_number_one, prison_number: nomis_prison_number_one) }
    let!(:prisoner_two) { create(:person, nomis_prison_number: nomis_prison_number_two, prison_number: nomis_prison_number_two) }

    it 'keeps people the same' do
      expect { importer.call }.not_to change(Person, :count)
    end

    it 'keeps profiles the same' do
      expect { importer.call }.not_to change(Profile, :count)
    end
  end

  context 'with no existing records' do
    it 'creates new `Person` records' do
      expect { importer.call }.to change(Person, :count).by(2)
    end

    it 'creates new `Profile` records' do
      expect { importer.call }.to change(Profile, :count).by(2)
    end

    it 'populates assessment answers' do
      importer.call

      assessment_answers = Person.last.profiles.first.assessment_answers

      expect(assessment_answers.count).to eq(2)
    end

    context 'with no alerts or personal care needs' do
      let(:alerts_response) { [] }
      let(:personal_care_needs_response) { [] }

      it 'creates new `Person` records' do
        expect { importer.call }.to change(Person, :count).by(2)
      end

      it 'creates new `Profile` records' do
        expect { importer.call }.to change(Profile, :count).by(2)
      end

      it 'does not populate assessment answers' do
        importer.call

        assessment_answers = Person.last.profiles.first.assessment_answers

        expect(assessment_answers).to be_empty
      end
    end
  end
end
