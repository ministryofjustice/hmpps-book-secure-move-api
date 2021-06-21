# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe PersonalCareNeeds::Importer do
  subject(:importer) do
    described_class.new(
      profile: profile,
      personal_care_needs: personal_care_needs,
    )
  end

  let(:person) { create(:person, :nomis_synced) }
  let(:profile) { person.latest_profile }
  let(:personal_care_needs) do
    [
      {
        offender_no: person.nomis_prison_number,
        problem_type: 'foo',
        problem_code: problem_code,
        problem_status: 'bar',
        problem_description: 'baz',
        start_date: '2010-06-21',
        end_date: '2010-06-21',
      },
    ]
  end
  let(:problem_code) { 'BRK' }

  let!(:default_question) { create(:assessment_question, :care_needs_fallback) }

  let!(:assessment_question) { create(:assessment_question, key: :special_vehicle, title: 'Requires special vehicle', category: 'health') }

  it 'appends a new assessment answer but does not save it' do
    expect { importer.call }.to change { profile.assessment_answers.count }.from(0).to(1)
    expect(profile.reload.assessment_answers.count).to eq(0)
  end

  context 'when the problem code is not recognised' do
    let(:problem_code) { 'foo' }

    it 'appends an assessment answer with the default values' do
      importer.call

      expect(profile.assessment_answers.first.as_json.symbolize_keys).to include(
        category: default_question.category,
        key: 'health_issue',
        nomis_alert_code: problem_code,
        nomis_alert_type_description: 'Unknown',
      )
    end
  end

  context 'when the problem code is recognised' do
    let(:problem_code) { 'BRK' }

    it 'appends an assessment answer with special vehicle and physical domain values' do
      importer.call

      expect(profile.assessment_answers.first.as_json.symbolize_keys).to include(
        category: assessment_question.category,
        key: assessment_question.key,
        nomis_alert_code: problem_code,
        nomis_alert_type_description: 'Medical',
      )
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
