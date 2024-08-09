# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  it { is_expected.to belong_to(:category).optional }
  it { is_expected.to belong_to(:person).required }
  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_many(:moves) } # NB: a profile can be re-used across multiple moves
  it { is_expected.to have_one(:person_escort_record) }
  it { is_expected.to have_one(:youth_risk_assessment) }
  it { is_expected.to validate_presence_of(:person) }

  describe '#validate_assessment_answers' do
    subject(:profile) { described_class.new(attributes) }

    let(:attributes)  { { person: create(:person) } }

    context 'with a valid assessment answer' do
      before do
        profile.assessment_answers = [
          { assessment_question_id: assessment_question.id },
        ]
      end

      let(:assessment_question) { create :assessment_question }

      it 'the profile is valid' do
        expect(profile).to be_valid
      end
    end

    context 'with an invalid assessment answer' do
      before do
        profile.assessment_answers = [
          { key: 'foo' },
        ]
      end

      it 'the profile is invalid' do
        expect(profile).not_to be_valid
      end
    end
  end

  describe '#assessment_answers' do
    let(:profile) { create :profile }
    let(:assessment_question) { create :assessment_question, category: 'health' }
    let(:assessment_answers) do
      [
        {
          title: 'Sight Impaired',
          comments: 'just a test',
          assessment_question_id: assessment_question.id,
          created_at: Date.civil(2019, 5, 30),
          expires_at: Date.civil(2019, 6, 30),
          nomis_alert_code: nil,
          nomis_alert_type: nil,
          nomis_alert_description: nil,
          nomis_alert_type_description: nil,
          imported_from_nomis: false,
        },
      ]
    end
    let(:expected_attributes) do
      assessment_answers.first.merge(
        created_at: '2019-05-30',
        expires_at: '2019-06-30',
        category: 'health',
        key: 'sight_impaired',
      ).stringify_keys
    end

    it 'serializes assessment answers correctly' do
      profile.assessment_answers = assessment_answers
      profile.save!
      reloaded_profile = described_class.find(profile.id)
      expect(reloaded_profile.assessment_answers&.first&.as_json).to eql expected_attributes
    end

    it 'deserializes assessment answers to an array' do
      profile.assessment_answers = assessment_answers
      expect(profile.assessment_answers).to be_an(Array)
    end

    it 'deserializes assessment answers to an array of AssessmentAnswer objects' do
      profile.assessment_answers = assessment_answers
      expect(profile.assessment_answers.first).to be_a(Profile::AssessmentAnswer)
    end
  end

  describe '#merge_assessment_answers!' do
    subject(:profile) { build :profile, assessment_answers: }

    let(:assessment_answers) do
      [
        Profile::AssessmentAnswer.new(
          key: 'hold_separately',
          imported_from_nomis: false,
          category: 'risk',
        ),
        Profile::AssessmentAnswer.new(
          key: 'ABC',
          imported_from_nomis: true,
          nomis_alert_type: 'A',
          nomis_alert_code: 'ABC',
          description: 'NOMIS imported item A',
          category: 'risk',
        ),
        Profile::AssessmentAnswer.new(
          key: 'XYZ',
          imported_from_nomis: true,
          nomis_alert_type: 'X',
          nomis_alert_code: 'XYZ',
          description: 'NOMIS imported item X',
          category: 'health',
        ),
        Profile::AssessmentAnswer.new(
          key: 'not_for_release',
          imported_from_nomis: false,
          category: 'health',
        ),
      ]
    end

    let(:imported_assessment_answers) do
      [
        Profile::AssessmentAnswer.new(
          key: 'DEF',
          imported_from_nomis: true,
          nomis_alert_type: 'D',
          nomis_alert_code: 'DEF',
          description: 'NOMIS imported item #2',
          category: 'health',
        ),
        Profile::AssessmentAnswer.new(
          key: 'HIJ',
          imported_from_nomis: true,
          nomis_alert_type: 'H',
          nomis_alert_code: 'HIJ',
          description: 'NOMIS imported item #3',
          category: 'health',
        ),
      ]
    end
    let(:category) { 'health' }

    before do
      profile.merge_assessment_answers!(imported_assessment_answers, category)
    end

    it 'overwrites previously imported answers and leaves other as they were' do
      expect(profile.assessment_answers.map(&:key)).to match_array(
        %w[not_for_release hold_separately ABC DEF HIJ],
      )
    end
  end

  context 'with versioning' do
    let(:profile) { create(:profile) }

    it 'has a create event' do
      expect(profile.versions.map(&:event)).to eq(%w[create])
    end
  end

  describe 'relationships' do
    it 'updates the parent record when updated' do
      profile = create(:profile, :with_assessment_answers)
      person = profile.person

      expect { profile.update(assessment_answers: []) }.to(change { person.reload.updated_at })
    end

    it 'updates the parent record when created' do
      person = create(:person_without_profiles)

      expect { create(:profile, person:) }.to(change { person.reload.updated_at })
    end
  end

  describe '#for_feed' do
    subject(:profile) { create(:profile, :with_person_escort_record) }

    let(:expected_json) do
      {
        'id' => profile.id,
        'person_id' => profile.person_id,
        'created_at' => be_a(Time),
        'updated_at' => be_a(Time),
        'assessment_answers' => [],
        'person_escort_record_id' => profile.person_escort_record_id,
      }
    end

    it 'generates a feed document' do
      expect(profile.for_feed).to include_json(expected_json)
    end
  end

  describe '.updated_at_range scope' do
    let(:updated_at_from) { Time.zone.yesterday.beginning_of_day }
    let(:updated_at_to) { Time.zone.yesterday.end_of_day }

    it 'returns the expected profiles' do
      create(:profile, updated_at: updated_at_from - 1.second)
      create(:profile, updated_at: updated_at_to + 1.second)
      on_start_profile = create(:profile, updated_at: updated_at_from)
      on_end_profile = create(:profile, updated_at: updated_at_to)

      actual_profiles = described_class.updated_at_range(updated_at_from, updated_at_to)

      expect(actual_profiles).to eq([on_start_profile, on_end_profile])
    end
  end
end
