# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonalCareNeeds::Importer do
  subject(:importer) do
    described_class.new(
      profile: profile,
      personal_care_needs: personal_care_needs,
    )
  end

  let(:person) { create :person }
  let(:profile) { person.latest_profile }
  let(:personal_care_needs) do
    [
      {
        problem_type: 'MATSTAT',
        problem_code: 'ACCU9',
        problem_status: 'ON',
        problem_description: 'Preg, acc under 9mths',
        start_date: '2010-06-21',
        end_date: '2010-06-21',
      },
    ]
  end

  let!(:pregnant_question) { create :assessment_question, key: :pregnant, title: 'Pregnant' }

  context 'with no relevant nomis alert mappings' do
    it 'creates a new assessment answer' do
      expect { importer.call }.to change { profile.reload.assessment_answers.count }.by(1)
    end

    it 'sets the nomis alert code' do
      importer.call
      expect(profile.reload.assessment_answers&.first&.nomis_alert_code).to eq 'ACCU9'
    end
  end
end
